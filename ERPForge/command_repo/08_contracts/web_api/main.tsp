import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

using TypeSpec.Http;
using TypeSpec.Rest;

@service({
  title: "ERPForge Scale-Invariant API Gateway",
  version: "1.0.0",
})
@doc("Единая точка проектирования (Design-First) для масштабной событийно-ориентированной ERP.")
@server("http://127.0.0.1:4010", "Локальный Mock/Стенд тестирования")
namespace ERPForge;

// ==========================================
// СЛОЙ 0: ОБЩИЕ ТИПЫ И СПРАВОЧНИКИ (SHARED KERNEL)
// ==========================================
model Enterprise {
  @doc("Уникальный идентификатор Tenant / Юрлица в рамках мультиарендности холдинга")
  id: string;
  name: string;
  @doc("Режим налогообложения (ОСНО, УСН Доходы, УСН Доходы-Расходы, Патент)")
  taxPolicy: "OSNO" | "USN_Income" | "USN_Expenses" | "Patent";
  inn: string;
  kpp?: string;
}

model Counterparty {
  id: string;
  enterpriseId: string;
  name: string;
  inn: string;
  type: "Customer" | "Supplier" | "Both";
}

model Nomenclature {
  id: string;
  sku: string;
  name: string;
  @doc("Базовая себестоимость закупки товара")
  baseCost: numeric;
  vatRate: int32; // Ставка НДС: 0, 10, 20
}

// ==========================================
// СЛОЙ 1: ПЕРВИЧНЫЕ ДОКУМЕНТЫ (BUSINESS LOGICA)
// ==========================================
model SalesInvoice {
  id: string;
  enterpriseId: string;
  counterpartyId: string;
  items: InvoiceItem[];
  @doc("Итоговая сумма документа")
  totalAmount: numeric;
  @doc("Статус проведения: Черновик (не влияет на регистры) или Проведен (записан в учет)")
  status: "Draft" | "Posted";
}

model InvoiceItem {
  nomenclatureId: string;
  quantity: int32;
  price: numeric;
}

// ==========================================
// СЛОЙ 3: АНАЛИТИКА И CQRS ПРОЕКЦИИ (PRODUCT ANALYSIS)
// ==========================================
model UnitEconomicsView {
  @doc("Маржинальный доход (Выручка минус Себестоимость списания COGS)")
  marginRevenue: numeric;
  @doc("Стоимость привлечения клиента")
  cac: numeric;
  @doc("Пожизненная ценность клиента в рамках когортного анализа")
  ltv: numeric;
  @doc("Срок окупаемости в месяцах относительно KPI таргетов")
  paybackPeriodMonths: int32;
  @doc("Коэффициент Churn Rate (отток клиентов для подписок)")
  churnRate: numeric;
}

// ==========================================
// СЛОЙ БИЛЛИНГА: СТРАТЕГИЯ СТАРТАПА (5k / 10k)
// ==========================================
model SubscriptionState {
  tenantId: string;
  currentTariff: "Base_5k" | "Pro_10k";
  isActive: boolean;
  validUntil: utcDateTime;
  @doc("Принудительный перевод системы в 'Только чтение' при задержке оплаты")
  isSuspended: boolean;
}

// ==========================================
// ИНТЕРФЕЙСЫ МАКРОСЕРВИСЫ (REST ENDPOINTS ДЛЯ GATEWAY)
// ==========================================

@route("/security")
interface IAMSecurity {
  @doc("Валидация JWT-сессии пользователя на уровне API Gateway")
  @post validateSession(@header authorization: string): { userId: string, isValid: boolean, permissions: string[] };
}

@route("/billing")
interface BillingAndSubscriptions {
  @doc("Проверка статуса подписки и лимитов тарифа")
  @get getLicenseStatus(@query tenantId: string): SubscriptionState;
  
  @doc("Активация лицензионного ключа / оплата")
  @post activateLicense(@query tenantId: string, @query key: string): SubscriptionState;
}

@route("/enterprises")
interface EnterprisesRegistry {
  @doc("Регистрация нового ООО или ИП в холдинге")
  @post createEnterprise(@body enterprise: Enterprise): Enterprise;
  
  @doc("Получение списка юрлиц")
  @get listEnterprises(): Enterprise[];
}

@route("/accounting")
interface FinancialAccounting {
  @doc("Создание или сохранение черновика расходной накладной")
  @post createInvoice(@body invoice: SalesInvoice): SalesInvoice;

  @doc("Команда проведения документа. Инициирует движок атомарных проводок на Rust и пишет операционные регистры.")
  @post postDocument(@path id: string): { status: "Posted", invoiceId: string, timestamp: utcDateTime };
}

@route("/analysis")
interface ProductAnalysis {
  @doc("CQRS-запрос на получение живой юнит-экономики по юрлицу из ClickHouse без нагрузки на OLTP-базу")
  @get getUnitEconomics(@query enterpriseId: string): UnitEconomicsView;
}

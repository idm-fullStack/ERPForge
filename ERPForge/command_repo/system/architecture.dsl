workspace "ERPForge" "Масштабно-инвариантная событийно-ориентированная ERP система нового поколения" {

    model {
        // ==========================================
        // АКТОРЫ И РОЛИ (Внешний контур)
        // ==========================================
        microUser = person "Микро-бизнес / Инди-хакер" "Владелец ИП или соло-разработчик. Использует ERP локально" "User"
        corpUser = person "Корпоративный пользователь" "Сотрудник крупного холдинга или SaaS-подписчик (Бухгалтер, Кладовщик)" "User"
        admin = person "Администратор SaaS платформы" "Контролирует глобальный биллинг, лимиты тарифов (5k/10k) и апдейты" "Admin"
        
        // ==========================================
        // ПРОГРАММНАЯ СИСТЕМА (Основная обертка)
        // ==========================================
        erp = softwareSystem "ERPForge Ecosystem" "Масштабно-инвариантная ERP-платформа. Сохраняет архитектурную симметрию на любом масштабе." {
            
            // СЛОЙ 1: FRONTEND & WHITE LABEL (React + Tauri)
            webApp = container "Web Client" "Основное клиентское Web-SPA приложение для работы в облаке" "React / TypeScript" "Frontend"
            adminPortal = container "Admin Portal" "Панель управления биллингом, лимитами и SaaS-клиентами" "React / TypeScript" "Frontend"
            mobileApp = container "Tauri Mobile App" "Кроссплатформенный ультралегкий мобильный клиент" "Rust / Tauri / React" "Frontend, Mobile"
            
            // СЛОЙ 2: API GATEWAY
            gateway = container "API Gateway" "Единая точка входа. Валидация JWT, Rate Limiting, White Label маршрутизация" "Traefik / Go" "Infrastructure"
            
            // СЛОЙ 3: RUST TRANSACTIONAL KERNEL (Транзакционное ядро)
            rustKernel = container "Rust Core Kernel" "Высоконагруженное ядро, движок метаданных, виртуальная машина конфигуратора" "Rust" "Backend, Highload"
            
            // СЛОЙ 5: ТРАНСПОРТ И АСИНХРОННАЯ ШИНА ( scale-invariant шина )
            messageBus = container "Event Bus (In-Memory / Redpanda)" "Масштабно-инвариантный транспорт: каналы памяти в Tauri или Redpanda/Kafka в облаке" "Rust Channels / Redpanda" "Infrastructure, Messaging"

            // СЛОЙ 4: МАКРОСЕРВИСЫ БИЗНЕС-ЛОГИКИ (14 контекстов вашей матрицы)
            securityMacro = container "IAM & Security Macroservice" "Управление сессиями, RBAC/ABAC правами и шифрованием" "Python / FastAPI" "Macroservice"
            auditMacro = container "Audit Log Macroservice" "Регистрация неизменяемого следа действий, хэш-цепочки SHA-256" "Python / FastAPI" "Macroservice"
            billingMacro = container "Billing & Subscriptions Macroservice" "Контроль тарификации, лимитов и лицензионных ключей" "Python / FastAPI" "Macroservice"
            accountingMacro = container "Financial Accounting Macroservice" "Журнал первичных документов и движок операционных регистров" "Python / FastAPI" "Macroservice"
            enterprisesMacro = container "Enterprises Macroservice" "Изоляция данных холдингов (Multi-tenancy) для ООО/ИП" "Python / FastAPI" "Macroservice"
            taxMacro = container "Tax Accounting Macroservice" "Налоги, формирование КДИР, декларации УСН/ОСНО и отчетность ФНС" "Python / FastAPI" "Macroservice"
            crmMacro = container "CRM & Sales Macroservice" "Управление лидами, сделками и коммерческими предложениями" "Python / FastAPI" "Macroservice"
            integrationMacro = container "Integrations Macroservice" "Коннекторы к Честному Знаку, Wildberries, DirectBank" "Python / FastAPI" "Macroservice"
            analysisMacro = container "Product Analysis Macroservice" "CQRS Проекции, расчет COGS и аналитика юнит-экономики" "Python / FastAPI" "Macroservice"
            reportMacro = container "Reporting Engine" "Конструктор динамических отчетов и сводных таблиц (Pivot)" "Python / FastAPI" "Macroservice"
            notificationMacro = container "Notifications Macroservice" "Пуш-уведомления на Honor 7A, Telegram-боты, Email-рассылки" "Python / FastAPI" "Macroservice"
            hrmMacro = container "HRM & Payroll Macroservice" "Сотрудники, табель учета рабочего времени, расчет ФОТ и зарплаты" "Python / FastAPI" "Macroservice"
            migrationMacro = container "Data Migration Macroservice" "Инструменты импорта и маппинга данных из 1С:Предприятие 7.7 / 8.3" "Python / FastAPI" "Macroservice"
            workflowMacro = container "Workflow Engine" "Движок бизнес-процессов (BPMN) для согласования документов и оплат" "Python / FastAPI" "Macroservice"

            // СЛОЙ 6: ХРАНЕНИЕ ДАННЫХ (CQRS Разделение)
            oltpDb = container "Primary DB (PostgreSQL / SQLite)" "OLTP-хранилище первичных документов с изоляцией Tenant ID" "PostgreSQL" "Database"
            olapDb = container "Analytics DB (ClickHouse)" "OLAP-хранилище плоских CQRS-проекций и истории логов аудита" "ClickHouse" "Database"
            cache = container "Distributed Cache & State (Redis)" "Кэширование сессий, конфигурационных манифестов и состояний BPMN" "Redis" "Database, Cache"
        }
        
        // ==========================================
        // СВЯЗИ УРОВНЯ 1: ЛОКАЛЬНЫЙ КОНТУР (EDGE)
        // ==========================================
        microUser -> mobileApp "Запускает ERP локально на ноутбуке/смартфоне без интернета" "IPC / In-Memory"
        mobileApp -> rustKernel "Вызывает ядро напрямую через Tauri-биндинги (без сети)" "Rust FFI"
        
        // ==========================================
        // СВЯЗИ УРОВНЯ 1: ОБЛАЧНЫЙ КОНТУР (ENTERPRISE / SaaS)
        // ==========================================
        corpUser -> webApp "Работает с распределенной ERP через браузер" "HTTPS"
        corpUser -> mobileApp "Синхронизирует данные склада и юнит-экономику по сети с Honor 7A" "REST / Websockets"
        admin -> adminPortal "Контролирует подписки за 5k/10k и биллинг холдингов" "HTTPS"
        
        // Внутренние контейнерные связи (Уровень 2)
        webApp -> gateway "Отправляет команды и запросы" "REST / JSON"
        adminPortal -> gateway "Управляет SaaS контуром" "REST / JSON"
        gateway -> rustKernel "Пробрасывает весь трафик через gRPC" "gRPC / Protobuf"
        rustKernel -> messageBus "Публикует системные события (Event Sourcing)" "Internal / Kafka Protocol"
        
        // Распределение событий по макросервисам
        messageBus -> securityMacro "Доставляет команды аутентификации" "Async"
        messageBus -> auditMacro "Записывает след действий пользователей" "Async"
        messageBus -> billingMacro "Доставляет события оплаты тарифов" "Async"
        messageBus -> accountingMacro "Доставляет команды проведения документов (PostDocument)" "Async"
        messageBus -> enterprisesMacro "Синхронизирует метаданные холдингов" "Async"
        messageBus -> taxMacro "Триггерит расчет налогов при проводках" "Async"
        messageBus -> crmMacro "Передает события по лидам и сделкам" "Async"
        messageBus -> integrationMacro "Маршрутизирует данные внешних маркетплейсов" "Async"
        messageBus -> analysisMacro "Доставляет изменения регистров для пересчета COGS" "Async"
        messageBus -> reportMacro "Обновляет структуры отчетов" "Async"
        messageBus -> notificationMacro "Инициирует отправку пушей и email" "Async"
        messageBus -> hrmMacro "Передает данные по табелям сотрудников" "Async"
        messageBus -> migrationMacro "Запускает пакетный импорт из 1С" "Async"
        messageBus -> workflowMacro "Управляет шагами согласования BPMN" "Async"
        
        // Взаимодействие макросервисов со слоем хранения данных
        accountingMacro -> oltpDb "Записывает первичку и справочники" "SQL"
        accountingMacro -> rustKernel "Вызывает движок атомарных проводок" "gRPC"
        rustKernel -> olapDb "Стримит неизменяемые движения регистров" "Native ClickHouse"
        auditMacro -> olapDb "Пишет хэш-цепочки аудит-лога" "Native ClickHouse"
        taxMacro -> oltpDb "Записывает налоговые обязательства" "SQL"
        crmMacro -> oltpDb "Управляет воронками продаж" "SQL"
        hrmMacro -> oltpDb "Начисляет ФОТ и зарплату" "SQL"
        workflowMacro -> cache "Хранит текущие стейты задач BPMN" "Redis"
        analysisMacro -> olapDb "Читает аналитические проекции и витрины юнит-экономики" "SQL"
        analysisMacro -> cache "Сбрасывает кэш метрик (LTV, CAC, Churn)" "Redis Protocol"
        securityMacro -> cache "Проверяет и инвалидирует сессии пользователей" "Redis Protocol"
    }
    
    views {
        // УРОВЕНЬ 1: ТЕПЕРЬ ОН ОТРЕЖАЕТ СУТЬ ИМЕННО ТАК, КАК НАДО
        systemContext erp "SystemContext" "Масштабно-инвариантный контекст: Edge (локально) и Enterprise (облако)" {
            include *
            autoLayout lr
        }
        
        // УРОВЕНЬ 2: Архитектура контейнеров
        container erp "Containers" "Масштабно-инвариантная архитектура 14 макросервисов" {
            include *
            autoLayout tb
        }
        
        styles {
            element "Person" {
                shape Person
                background #0f172a
                color #ffffff
            }
            element "Frontend" {
                shape WebBrowser
                background #38bdf8
                color #0f172a
            }
            element "Macroservice" {
                shape Hexagon
                background #4ade80
                color #0f172a
                icon "https://tiangolo.com"
            }
            element "Highload" {
                shape Box
                background #f43f5e
                color #ffffff
            }
            element "Messaging" {
                shape Pipe
                background #fb923c
                color #0f172a
            }
            element "Database" {
                shape Cylinder
                background #a855f7
                color #ffffff
            }
            element "Infrastructure" {
                shape Box
         
            }
            }
            }
        
    }


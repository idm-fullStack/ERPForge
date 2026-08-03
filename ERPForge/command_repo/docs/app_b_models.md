# Приложение Б. Модели данных

## Базовые сущности

```yaml
Enterprise:
  id: uuid
  name: string
  inn: string
  tax_system: enum

User:
  id: uuid
  email: string
  password_hash: string
  role_ids: array

Document:
  id: uuid
  number: string
  date: date
  status: enum
  total_amount: numeric

LedgerEntry:
  id: uuid
  account_debit: string
  account_credit: string
  amount: numeric
  posting_date: date
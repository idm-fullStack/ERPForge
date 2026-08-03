# 8. Безопасность

## 8.1. Аутентификация

- JWT-токены (access + refresh)
- 2FA (TOTP, SMS, Email)
- SSO (Google, GitHub, Yandex)

## 8.2. Авторизация (RBAC)

Роли:
- `super_admin` — полный доступ
- `admin` — администрирование клиента
- `accountant` — бухгалтер
- `manager` — руководитель
- `sales` — менеджер продаж
- `hrm` — HR-специалист
- `auditor` — аудитор
- `readonly` — только чтение

## 8.3. Аудит

- Полный лог всех действий
- Хранение 5 лет
- Цифровая подпись

## 8.4. Шифрование

- At Rest: AES-256
- In Transit: TLS 1.3
- Пароли: Argon2id
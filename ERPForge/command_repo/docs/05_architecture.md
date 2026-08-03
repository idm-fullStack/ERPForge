# 5. Архитектура системы

## 5.1. Уровни архитектуры

| Уровень | Технологии |
|---------|------------|
| Frontend | React + TypeScript, Tauri (Mobile) |
| Backend | Rust (ядро) + Python (сервисы) |
| API Gateway | Kong / Traefik |
| Базы данных | PostgreSQL (OLTP), ClickHouse (Analytics) |
| Кэш | Redis |
| Шина событий | Redpanda / Kafka |
| Инфраструктура | Kubernetes + Terraform |

## 5.2. C4-модель

```plantuml
@startuml
!include <C4/C4_Container>
...
@enduml
# Приложение А. Спецификация API

Полная спецификация API представлена в файле:

[openapi.yaml](https://erpforge.github.io/command_repo/08_contracts/web_api/generated/openapi.yaml)

Основные эндпоинты:

| Метод | Путь | Описание |
|-------|------|----------|
| POST | /auth/login | Вход в систему |
| POST | /auth/logout | Выход |
| GET | /enterprises | Список юрлиц |
| POST | /enterprises | Создание юрлица |
| GET | /documents | Список документов |
| POST | /documents/{id}/post | Проведение документа |
| GET | /analysis/unit-economics | Юнит-экономика |
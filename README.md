## Быстрый старт

### Требования

- Свободные порты на хосте: **2181**, **9095**, **8080**, **8123**, **9000**
- Файл `data/train.csv` (хранится в Git LFS: после клонирования выполнить `git lfs pull`)

### Запуск

```bash
# 1. Создать файл окружения с кредами ClickHouse
cp .env.example .env

# 2. Собрать и поднять весь стек
docker compose up -d --build
```

При старте ClickHouse создаёт таблицы из `sql/ddl_baseline.sql` и `sql/ddl_optimized.sql`, а контейнер `producer` загружает `data/train.csv` в топик Kafka `transactions`. Дождаться окончания загрузки:

```bash
docker compose logs -f producer   # "Готово, всего отправлено: 786431"
```

Загрузить данные в Kafka можно и вручную с хоста:

```bash
uv sync
KAFKA_BROKERS=localhost:9095 uv run python producer/main.py --file data/train.csv
```

### Получение результата

```bash
./scripts/run_query.sh optimized   # -> results/optimized_result.csv
./scripts/run_query.sh baseline    # -> results/baseline_result.csv
```

## Структура проекта

```
.
├── producer/                   # загрузка CSV в Kafka
│   ├── main.py                 # точка входа
│   ├── kafka_broker.py         # чтение CSV и отправка в топик
│   ├── logger_config.py        # настройка loguru
│   └── Dockerfile
├── sql/
│   ├── ddl_baseline.sql        # таблицы Kafka → MV → MergeTree (базовая версия)
│   ├── ddl_optimized.sql       # оптимизированная версия DDL
│   └── sql_query.sql           # категория наибольшей транзакции по каждому штату
├── results/                    # результаты запроса в CSV
├── scripts/run_query.sh        # выполнение запроса и выгрузка в CSV
├── data/                       # исходные CSV (Git LFS)
├── dbt/                        # dbt-проект поверх optimized.transactions
├── docs/                       # артефакты dbt для PR: DAG, лог тестов
├── docker-compose.yaml
├── pyproject.toml / uv.lock    # окружение uv
└── .env.example                # шаблон переменных окружения
```

## Версии

- `dbt-core` 1.12.6
- `dbt-clickhouse` 1.10.3
- ClickHouse 25.8

## Витрины (6)

- `mart_daily_state_metrics`: дневные метрики по штатам
- `mart_fraud_by_category`: фрод по категориям
- `mart_fraud_by_state`: фрод по штатам
- `mart_customer_risk_profile`: профиль риска клиентов
- `mart_hourly_fraud_pattern`: фрод по дням и часам, флаг `is_high_risk_window`
- `mart_merchant_analytics`: метрики мерчантов, флаг `is_suspicious`

## Тесты

`dbt test`: `PASS=58 WARN=0 ERROR=0 SKIP=0`, полный лог в `docs/dbt_test.log`.

- 46 generic-тестов: dbt core, `dbt_utils`, `dbt_expectations`
- 4 singular-теста: `assert_no_negative_amounts`, `assert_fraud_rate_bounds`, `assert_marts_reconcile_with_staging`, `assert_fraud_not_exceeds_totals`
- 8 unit-тестов: `stg_transactions` и все витрины

## Артефакты

- Макросы: `amount_bucket`, `percentage`
- Пакеты: `dbt_utils`, `dbt_date`, `dbt_expectations`
- `schema.yml` с описаниями и тестами
- `dbt/Makefile`

## Конфиг sqlfluff

```ini
[sqlfluff]
dialect = clickhouse
templater = jinja
max_line_length = 120
exclude_rules = ST06

[sqlfluff:templater:jinja]
apply_dbt_builtins = True
load_macros_from_path = macros
library_path = sqlfluff_libs

[sqlfluff:indentation]
tab_space_size = 4

[sqlfluff:rules:capitalisation.keywords]
capitalisation_policy = lower
```

## Конфиг pre-commit

```yaml
repos:
  - repo: https://github.com/sqlfluff/sqlfluff
    rev: 4.5.0
    hooks:
      - id: sqlfluff-lint
        args: [--dialect, clickhouse]
        files: ^dbt/(models|tests)/.*\.sql$
      - id: sqlfluff-fix
        args: [--dialect, clickhouse]
        files: ^dbt/(models|tests)/.*\.sql$
```

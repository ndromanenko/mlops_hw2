with staging_totals as (
    select
        count() as transactions_count,
        sum(is_fraud) as fraud_count
    from {{ ref('stg_transactions') }}
),

mart_totals as (
    select
        'daily' as mart,
        sum(transactions_count) as transactions_count,
        null as fraud_count
    from {{ ref('mart_daily_state_metrics') }}
    union all
    select
        'category' as mart,
        sum(total_transactions) as transactions_count,
        sum(fraud_transactions) as fraud_count
    from {{ ref('mart_fraud_by_category') }}
    union all
    select
        'state' as mart,
        sum(total_transactions) as transactions_count,
        sum(fraud_transactions) as fraud_count
    from {{ ref('mart_fraud_by_state') }}
    union all
    select
        'customer' as mart,
        sum(total_transactions) as transactions_count,
        sum(fraud_transactions) as fraud_count
    from {{ ref('mart_customer_risk_profile') }}
    union all
    select
        'hourly' as mart,
        sum(total_transactions) as transactions_count,
        sum(fraud_transactions) as fraud_count
    from {{ ref('mart_hourly_fraud_pattern') }}
    union all
    select
        'merchant' as mart,
        sum(total_transactions) as transactions_count,
        sum(fraud_transactions) as fraud_count
    from {{ ref('mart_merchant_analytics') }}
)

select mart_totals.*
from mart_totals
cross join staging_totals
where
    mart_totals.transactions_count != staging_totals.transactions_count
    or mart_totals.fraud_count != staging_totals.fraud_count

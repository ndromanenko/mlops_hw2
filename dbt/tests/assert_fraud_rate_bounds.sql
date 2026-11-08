with fraud_rates as (
    select
        'category' as mart,
        fraud_rate
    from {{ ref('mart_fraud_by_category') }}
    union all
    select
        'state' as mart,
        fraud_rate
    from {{ ref('mart_fraud_by_state') }}
    union all
    select
        'customer' as mart,
        fraud_rate
    from {{ ref('mart_customer_risk_profile') }}
    union all
    select
        'hourly' as mart,
        fraud_rate
    from {{ ref('mart_hourly_fraud_pattern') }}
    union all
    select
        'merchant' as mart,
        fraud_rate
    from {{ ref('mart_merchant_analytics') }}
)

select
    mart,
    fraud_rate
from fraud_rates
where fraud_rate < 0 or fraud_rate > 100

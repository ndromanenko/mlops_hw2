{{ config(order_by='(day_of_week, transaction_hour)') }}

with hourly_totals as (
    select
        day_of_week,
        transaction_hour,
        count() as total_transactions,
        sum(is_fraud) as fraud_transactions
    from {{ ref('stg_transactions') }}
    group by
        day_of_week,
        transaction_hour
),

hourly_with_overall as (
    select
        *,
        sum(fraud_transactions) over () / sum(total_transactions) over () as overall_fraud_share
    from hourly_totals
)

select
    day_of_week,
    transaction_hour,
    total_transactions,
    fraud_transactions,
    {{ percentage('fraud_transactions', 'total_transactions') }} as fraud_rate,
    toUInt8(fraud_transactions / total_transactions >= {{ var('high_risk_window_multiplier') }} * overall_fraud_share
    ) as is_high_risk_window
from hourly_with_overall

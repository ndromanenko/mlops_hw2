{{ config(order_by='customer_id') }}

with customer_totals as (
    select
        customer_id,
        count() as total_transactions,
        sum(is_fraud) as fraud_transactions,
        round(avg(amount_usd), 2) as avg_amount,
        min(transaction_time) as first_transaction_at,
        max(transaction_time) as last_transaction_at
    from {{ ref('stg_transactions') }}
    group by customer_id
),

customer_rates as (
    select
        *,
        {{ percentage('fraud_transactions', 'total_transactions') }} as fraud_rate
    from customer_totals
)

select
    *,
    multiIf(
        fraud_rate >= {{ var('customer_high_risk_fraud_rate') }}, 'HIGH',
        fraud_rate >= {{ var('customer_medium_risk_fraud_rate') }}, 'MEDIUM',
        'LOW'
    ) as risk_level
from customer_rates

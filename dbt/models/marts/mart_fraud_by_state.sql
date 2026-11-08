{{ config(order_by='state_code') }}

with state_totals as (
    select
        state_code,
        count() as total_transactions,
        sum(is_fraud) as fraud_transactions,
        uniqExact(customer_id) as unique_customers,
        uniqExact(merchant_name) as unique_merchants,
        round(sum(amount_usd), 2) as total_amount,
        round(sumIf(amount_usd, is_fraud = 1), 2) as fraud_amount
    from {{ ref('stg_transactions') }}
    group by state_code
)

select
    state_code,
    total_transactions,
    fraud_transactions,
    {{ percentage('fraud_transactions', 'total_transactions') }} as fraud_rate,
    unique_customers,
    unique_merchants,
    total_amount,
    fraud_amount
from state_totals

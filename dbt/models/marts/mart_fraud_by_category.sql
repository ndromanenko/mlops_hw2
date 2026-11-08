{{ config(order_by='category') }}

with category_totals as (
    select
        category,
        count() as total_transactions,
        sum(is_fraud) as fraud_transactions,
        round(sum(amount_usd), 2) as total_amount,
        round(sumIf(amount_usd, is_fraud = 1), 2) as fraud_amount
    from {{ ref('stg_transactions') }}
    group by category
)

select
    category,
    total_transactions,
    fraud_transactions,
    {{ percentage('fraud_transactions', 'total_transactions') }} as fraud_rate,
    total_amount,
    fraud_amount
from category_totals

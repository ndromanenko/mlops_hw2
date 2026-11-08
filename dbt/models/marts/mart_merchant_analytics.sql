{{ config(order_by='merchant_name') }}

with merchant_totals as (
    select
        merchant_name,
        count() as total_transactions,
        sum(is_fraud) as fraud_transactions,
        round(sum(amount_usd), 2) as total_amount
    from {{ ref('stg_transactions') }}
    group by merchant_name
),

merchant_with_overall as (
    select
        *,
        sum(fraud_transactions) over () / sum(total_transactions) over () as overall_fraud_share
    from merchant_totals
)

select
    merchant_name,
    total_transactions,
    fraud_transactions,
    {{ percentage('fraud_transactions', 'total_transactions') }} as fraud_rate,
    total_amount,
    toUInt8(
        total_transactions >= {{ var('suspicious_merchant_min_transactions') }}
        and fraud_transactions / total_transactions
        >= {{ var('suspicious_merchant_multiplier') }} * overall_fraud_share
    ) as is_suspicious
from merchant_with_overall

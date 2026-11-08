with fraud_vs_totals as (
    select
        'category' as mart,
        total_transactions,
        fraud_transactions,
        total_amount,
        fraud_amount
    from {{ ref('mart_fraud_by_category') }}
    union all
    select
        'state' as mart,
        total_transactions,
        fraud_transactions,
        total_amount,
        fraud_amount
    from {{ ref('mart_fraud_by_state') }}
    union all
    select
        'customer' as mart,
        total_transactions,
        fraud_transactions,
        null as total_amount,
        null as fraud_amount
    from {{ ref('mart_customer_risk_profile') }}
)

select
    mart,
    total_transactions,
    fraud_transactions,
    total_amount,
    fraud_amount
from fraud_vs_totals
where
    fraud_transactions > total_transactions
    or fraud_amount > total_amount

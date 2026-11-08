{{ config(
    order_by='(transaction_date, state_code)',
    partition_by='toYYYYMM(transaction_date)'
) }}

select
    transaction_date,
    state_code,
    count() as transactions_count,
    round(sum(amount_usd), 2) as total_amount,
    round(avg(amount_usd), 2) as avg_amount,
    round(quantileExact(0.95)(amount_usd), 2) as p95_amount, -- noqa: LT01
    {{ percentage('sum(is_large)', 'count()') }} as large_transactions_share
from {{ ref('stg_transactions') }}
group by
    transaction_date,
    state_code

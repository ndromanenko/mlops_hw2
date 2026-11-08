select
    transaction_id,
    amount_usd
from {{ ref('stg_transactions') }}
where amount_usd < 0

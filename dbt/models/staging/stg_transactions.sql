with source_transactions as (
    select * from {{ source('transactions_db', 'transactions') }}
),

normalized as (
    select
        transaction_time,
        toDate(transaction_time) as transaction_date,
        toHour(transaction_time) as transaction_hour,
        replaceRegexpOne(merch, '^fraud_', '') as merchant_name,
        lower(trimBoth(toString(cat_id))) as category,
        toFloat64(amount) as amount_usd,
        trimBoth(toString(name_1)) as first_name,
        trimBoth(toString(name_2)) as last_name,
        upper(toString(gender)) as gender,
        upper(trimBoth(toString(us_state))) as state_code,
        lat as customer_lat,
        lon as customer_lon,
        merchant_lat,
        merchant_lon,
        target as is_fraud
    from source_transactions
),

enriched as (
    select
        {{ dbt_utils.generate_surrogate_key([
            'transaction_time', 'merchant_name', 'amount_usd',
            'first_name', 'last_name', 'customer_lat', 'customer_lon'
        ]) }} as transaction_id,
        {{ dbt_utils.generate_surrogate_key([
            'first_name', 'last_name', 'customer_lat', 'customer_lon'
        ]) }} as customer_id,
        transaction_time,
        transaction_date,
        transaction_hour,
        {{ dbt_date.day_of_week('transaction_time') }} as day_of_week,
        {{ dbt_date.day_name('transaction_time', short=false) }} as day_name,
        merchant_name,
        category,
        amount_usd,
        {{ amount_bucket('amount_usd') }} as amount_bucket,
        toUInt8(amount_usd >= {{ var('large_amount_threshold') }}) as is_large,
        first_name,
        last_name,
        gender,
        state_code,
        customer_lat,
        customer_lon,
        merchant_lat,
        merchant_lon,
        is_fraud
    from normalized
)

select * from enriched

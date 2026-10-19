CREATE DATABASE IF NOT EXISTS optimized;

CREATE TABLE optimized.transactions (
    transaction_time DateTime,
    merch LowCardinality(String),
    cat_id LowCardinality(String),
    amount Decimal32(2),
    name_1 LowCardinality(String),
    name_2 LowCardinality(String),
    gender LowCardinality(String),
    street String,
    one_city LowCardinality(String),
    us_state LowCardinality(String),
    post_code UInt32,
    lat Float64,
    lon Float64,
    population_city UInt32,
    jobs LowCardinality(String),
    merchant_lat Float64,
    merchant_lon Float64,
    target UInt8,

    PROJECTION max_amount_by_state (
        SELECT us_state, argMax(cat_id, amount), max(amount)
        GROUP BY us_state
    )
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(transaction_time)
ORDER BY (us_state, cat_id, transaction_time);

CREATE TABLE optimized.kafka_transactions_stream (
    transaction_time String,
    merch String,
    cat_id String,
    amount Decimal32(2),
    name_1 String,
    name_2 String,
    gender String,
    street String,
    one_city String,
    us_state String,
    post_code UInt32,
    lat Float64,
    lon Float64,
    population_city UInt32,
    jobs String,
    merchant_lat Float64,
    merchant_lon Float64,
    target UInt8
) ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'transactions',
    kafka_group_name = 'clickhouse_optimized',
    kafka_num_consumers = 1,
    kafka_format = 'JSONEachRow';

CREATE MATERIALIZED VIEW optimized.mv_kafka_to_transactions
TO optimized.transactions
AS SELECT
    parseDateTimeBestEffort(transaction_time) AS transaction_time,
    merch,
    cat_id,
    amount,
    name_1,
    name_2,
    gender,
    street,
    one_city,
    us_state,
    post_code,
    lat,
    lon,
    population_city,
    jobs,
    merchant_lat,
    merchant_lon,
    target
FROM optimized.kafka_transactions_stream;

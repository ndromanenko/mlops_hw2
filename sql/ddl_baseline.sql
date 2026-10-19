CREATE DATABASE IF NOT EXISTS baseline;

CREATE TABLE baseline.transactions (
    transaction_time String,
    merch String,
    cat_id String,
    amount Float64,
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
) ENGINE = MergeTree()
ORDER BY tuple();

CREATE TABLE baseline.kafka_transactions_stream (
    transaction_time String,
    merch String,
    cat_id String,
    amount Float64,
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
    kafka_group_name = 'clickhouse_baseline',
    kafka_num_consumers = 1,
    kafka_format = 'JSONEachRow';

CREATE MATERIALIZED VIEW baseline.mv_kafka_to_transactions
TO baseline.transactions
AS SELECT *
FROM baseline.kafka_transactions_stream;

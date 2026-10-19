import csv
import json
import os
from pathlib import Path

from kafka import KafkaProducer

from logger_config import get_logger

BROKERS = os.getenv("KAFKA_BROKERS", "kafka:9092")
TRANSACTIONS_TOPIC = os.getenv("KAFKA_TOPIC", "transactions")
LOG_EVERY = int(os.getenv("LOG_EVERY", "100000"))

log = get_logger("producer")


def send_csv(csv_path: Path, limit: int | None = None) -> int:
    producer = KafkaProducer(
        bootstrap_servers=BROKERS,
        value_serializer=lambda x: json.dumps(x).encode("utf-8"),
        linger_ms=50,
        batch_size=256 * 1024,
        compression_type="gzip",
    )
    log.info(f"Отправляю '{csv_path}' в топик '{TRANSACTIONS_TOPIC}' ({BROKERS})")

    sent = 0
    with csv_path.open(newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            producer.send(TRANSACTIONS_TOPIC, value=row)
            sent += 1
            if sent % LOG_EVERY == 0:
                log.info(f"Отправлено строк: {sent}")
            if limit and sent >= limit:
                break

    producer.flush()
    producer.close()
    log.info(f"Готово, всего отправлено: {sent}")
    return sent

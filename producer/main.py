import argparse
import os
from pathlib import Path

from kafka_broker import send_csv
from logger_config import setup_logger


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Загрузка CSV с транзакциями в топик Kafka")
    parser.add_argument(
        "--file",
        type=Path,
        default=Path(os.getenv("CSV_PATH", "data/train.csv")),
        help="путь к CSV файлу",
    )
    parser.add_argument("--limit", type=int, default=None, help="отправить только первые N строк")
    return parser.parse_args()


if __name__ == "__main__":
    setup_logger()
    args = parse_args()
    send_csv(args.file, args.limit)

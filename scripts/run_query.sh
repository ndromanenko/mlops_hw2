set -euo pipefail
cd "$(dirname "$0")/.."
source .env

DB="${1:-optimized}"
OUT="results/${DB}_result.csv"
mkdir -p results

docker compose exec -T clickhouse clickhouse-client \
  --user "$CLICKHOUSE_USER" --password "$CLICKHOUSE_PASSWORD" \
  --database "$DB" \
  --queries-file /sql/sql_query.sql \
  --format CSVWithNames > "$OUT"

echo "Результат сохранён в $OUT ($(($(wc -l < "$OUT") - 1)) строк)"

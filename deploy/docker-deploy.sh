#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-grok2api}"
APP_PORT="${APP_PORT:-8000}"
IMAGE_NAME="${IMAGE_NAME:-luka762/grok2api}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
TZ="${TZ:-Asia/Shanghai}"
DATA_DIR="${DATA_DIR:-data}"
LOG_DIR="${LOG_DIR:-logs}"

cat > docker-compose.yml <<'COMPOSE'
services:
  app:
    container_name: ${APP_NAME:-grok2api}
    image: ${IMAGE_NAME:-luka762/grok2api}:${IMAGE_TAG:-latest}
    restart: unless-stopped
    ports:
      - "${APP_PORT:-8000}:${SERVER_PORT:-8000}"
    volumes:
      - ./${DATA_DIR:-data}:/app/data
      - ./${LOG_DIR:-logs}:/app/logs
    environment:
      TZ: ${TZ:-Asia/Shanghai}
      LOG_LEVEL: ${LOG_LEVEL:-INFO}
      LOG_FILE_ENABLED: ${LOG_FILE_ENABLED:-true}
      SERVER_HOST: 0.0.0.0
      SERVER_PORT: ${SERVER_PORT:-8000}
      SERVER_WORKERS: ${SERVER_WORKERS:-1}
      DATA_DIR: /app/data
      LOG_DIR: /app/logs
      ACCOUNT_STORAGE: ${ACCOUNT_STORAGE:-local}
      ACCOUNT_LOCAL_PATH: ${ACCOUNT_LOCAL_PATH:-/app/data/accounts.db}
      ACCOUNT_REDIS_URL: ${ACCOUNT_REDIS_URL:-}
      ACCOUNT_MYSQL_URL: ${ACCOUNT_MYSQL_URL:-}
      ACCOUNT_POSTGRESQL_URL: ${ACCOUNT_POSTGRESQL_URL:-}
COMPOSE

if [ ! -f .env ]; then
  cat > .env <<ENV
APP_NAME=${APP_NAME}
APP_PORT=${APP_PORT}
IMAGE_NAME=${IMAGE_NAME}
IMAGE_TAG=${IMAGE_TAG}
TZ=${TZ}
SERVER_PORT=8000
SERVER_WORKERS=1
LOG_LEVEL=INFO
LOG_FILE_ENABLED=true
DATA_DIR=${DATA_DIR}
LOG_DIR=${LOG_DIR}
ACCOUNT_STORAGE=local
ACCOUNT_LOCAL_PATH=/app/data/accounts.db
ENV
fi

mkdir -p "$DATA_DIR" "$LOG_DIR"

echo "done"
echo "next: docker compose pull && docker compose up -d"

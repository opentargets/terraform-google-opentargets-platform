#!/bin/bash

echo "[LAUNCH] Open Targets Platform API"
docker run -d \
  --log-driver=gcplogs \
  -p ${OTP_API_PORT}:${OTP_API_PORT} \
  -e SLICK_CLICKHOUSE_URL='${SLICK_CLICKHOUSE_URL}' \
  -e ELASTICSEARCH_HOST='${ELASTICSEARCH_HOST}' \
  quay.io/opentargets/platform-api-beta:${PLATFORM_API_VERSION}

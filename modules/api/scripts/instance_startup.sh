#!/bin/bash
echo "[LAUNCH] Open Targets Platform API"
set +x
docker run -d \
  -p ${OTP_API_PORT}:${OTP_API_PORT} \
  --log-driver=gcplogs \
  -e SLICK_CLICKHOUSE_URL='${SLICK_CLICKHOUSE_URL}' \
  -e ELASTICSEARCH_HOST='${ELASTICSEARCH_HOST}' \
  -e META_API_MAJOR='${API_VERSION_MAJOR}' \
  -e META_API_MINOR='${API_VERSION_MINOR}' \
  -e META_API_PATCH='${API_VERSION_PATCH}' \
  -e META_DATA_YEAR='${API_DATA_YEAR}' \
  -e META_DATA_MONTH='${API_DATA_MONTH}' \
  -e META_DATA_ITERATION='${API_DATA_ITER}' \
  quay.io/opentargets/platform-api:${PLATFORM_API_VERSION}

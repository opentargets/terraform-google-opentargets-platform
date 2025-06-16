#!/bin/bash
echo "[LAUNCH] Open Targets Platform API"
# Installing docker compose
set +x
# remove man
apt-get remove -y --purge man-db

# update package lists
apt-get update -y

# install dependencies
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  git \
  build-essential

# add docker gpg key
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# add docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# update package lists again
apt-get update -y

# install docker
apt-get install -y docker-ce docker-ce-cli containerd.io
  
# Create compose file and start containers
mkdir -p /opt/ot-api
cd /opt/ot-api
cat << EOF >> compose.yml
services:
  clickhouse:
    image: ghcr.io/opentargets/platform-api:${PLATFORM_API_VERSION}
    logging:
      driver: gcplogs
    environment:
      - SLICK_CLICKHOUSE_URL=${SLICK_CLICKHOUSE_URL}
      - ELASTICSEARCH_HOST=${ELASTICSEARCH_HOST}
      - META_APIVERSION_MAJOR=${API_VERSION_MAJOR}
      - META_APIVERSION_MINOR=${API_VERSION_MINOR}
      - META_APIVERSION_PATCH=${API_VERSION_PATCH}
      - META_DATA_YEAR=${API_DATA_YEAR}
      - META_DATA_MONTH=${API_DATA_MONTH}
      - META_DATA_ITERATION=${API_DATA_ITER}
      - PLATFORM_API_IGNORE_CACHE=${API_IGNORE_CACHE}
      - JVM_XMS=${JVM_XMS}
      - JVM_XMX=${JVM_XMX}
    ports:
      - ${OTP_API_PORT}:${OTP_API_PORT}
  node_exporter:
    image: quay.io/prometheus/node-exporter:latest
    container_name: node_exporter
    command:
      - '--path.rootfs=/host'
    network_mode: host
    pid: host
    restart: unless-stopped
    volumes:
      - '/:/host:ro,rslave'
EOF

logi "execute docker compose up"
docker compose up -d
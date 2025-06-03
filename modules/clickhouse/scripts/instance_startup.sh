#!/bin/bash
echo "[LAUNCH] Open Targets OpenSearch"
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

# Local environment
export path_mount_ch_data_volume="/mnt/disks/chdata"
export device_disk_ch_data=${GCP_DEVICE_DISK_PREFIX}${DATA_DISK_DEVICE_NAME_CH}

# Logging functions
function log() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]$@"
}
function Logi() {
  log "[INFO] $@"
}

function Logw() {
  log "[WARNING] $@"
}

function Loge() {
  log "[ERROR] $@"
}

# Prepare the data volume
logi "Prepare data mount point at '$${path_mount_ch_data_volume}'"
mkdir -p $${path_mount_ch_data_volume}
logi "Mount Clickhouse data disk device '$${device_disk_ch_data}' at '$${path_mount_ch_data_volume}'"
mount $${device_disk_ch_data} $${path_mount_ch_data_volume}

# Launch Clickhouse
logi "Launching Clickhose via docker image '${DOCKER_IMAGE_CLICKHOUSE}'"

logi "Generating compose file"
# Create the docker-compose file
mkdir -p /opt/ot-ch
cd /opt/ot-ch
cat << EOF >> compose.yml
services:
  clickhouse:
    image: ${DOCKER_IMAGE_CLICKHOUSE}
    container_name: $${otp-ch}
    logging:
      driver: gcplogs
    ports:
      - "9000:9000"
      - "8123:8123"
      - "9363:9363"
    volumes:
      - $${path_mount_ch_data_volume}/config.d:/etc/clickhouse-server/config.d
      - $${path_mount_ch_data_volume}/users.d:/etc/clickhouse-server/users.d
      - $${path_mount_ch_data_volume}/data:/var/lib/clickhouse
    ulimits:
      nofile:
        soft: 262144
        hard: 262144
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
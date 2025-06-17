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
export path_mount_ch_data_volume=${CH_DATA_VOLUME}
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

logi "Generating compose file"
# Create the docker-compose file
mkdir -p /opt/ot-ch
cd /opt/ot-ch
curl -s -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker_compose' > compose.yml

logi "execute docker compose up"
docker compose up -d
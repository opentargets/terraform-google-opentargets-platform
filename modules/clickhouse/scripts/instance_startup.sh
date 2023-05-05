#!/bin/bash
# This is a placeholder startup script, as it is currently not needed by Clickhouse

# Local environment
export path_mount_ch_data_volume="/mnt/chdata"
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
docker run --rm -d \
    --name otp-ch \
    --log-driver=gcplogs \
    -p 9000:9000 \
    -p 8123:8123 \
    -v $${path_mount_ch_data_volume}/config.d:/etc/clickhouse-server/config.d \
    -v $${path_mount_ch_data_volume}/users.d:/etc/clickhouse-server/users.d \
    -v $${path_mount_ch_data_volume}/data:/var/lib/clickhouse \
    --ulimit nofile=262144:262144 \
    ${DOCKER_IMAGE_CLICKHOUSE}
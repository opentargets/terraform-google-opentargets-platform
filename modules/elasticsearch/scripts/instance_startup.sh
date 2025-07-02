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
export PATH_MOUNT_ES_DATA_VOLUME="/mnt/disks/esdata"
export DEVICE_DISK_ES_DATA=${GCP_DEVICE_DISK_PREFIX}${DATA_DISK_DEVICE_NAME_ES}
export PATH_ES_DATA_VOLUME=$${PATH_MOUNT_ES_DATA_VOLUME}/data
export DOCKER_VOLUME_NAME_ES="esdata"
export DOCKER_IMAGE_STRING_ES="opensearchproject/opensearch:${ELASTIC_SEARCH_VERSION}"
export ES_DOCKER_CONTAINER_NAME="otp-es"
export ES_CLUSTER_NAME=`hostname`
export ES_VOL_PATH_DATA=$${PATH_ES_DATA_VOLUME}

# Logging functions
function log() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]$@"
}
function logi() {
  log "[INFO] $@"
}

function logw() {
  log "[WARNING] $@"
}

function loge() {
  log "[ERROR] $@"
}

# Prepare the data volume
logi "Prepare data mount point at '$${PATH_MOUNT_ES_DATA_VOLUME}'"
mkdir -p $${PATH_MOUNT_ES_DATA_VOLUME}
logi "Mount Elastic Seardh data disk device '$${DEVICE_DISK_ES_DATA}' at '$${PATH_MOUNT_ES_DATA_VOLUME}'"
mount $${DEVICE_DISK_ES_DATA} $${PATH_MOUNT_ES_DATA_VOLUME}
logi "Create a Docker volume at the Elastic Search Data Volume '$${DOCKER_VOLUME_NAME_ES}' bound to folder '$${PATH_ES_DATA_VOLUME}'"

# Launch Elastic Search
logi "Running Elastic Search via Docker, using image $${DOCKER_IMAGE_STRING_ES}"
logi "Setting vm.max_map_count to 262144"
sysctl -w vm.max_map_count=262144
# Get machine available memory (KiB)
export MACHINE_SIZE=`cat /proc/meminfo | grep MemTotal | grep -o '[0-9]\+'`
# Use all the machine memory for the JVM minus 1GiB
export JVM_SIZE=`expr $(expr $MACHINE_SIZE / 1048576) - 1`
export JVM_SIZE_HALF=`expr $MACHINE_SIZE / 2097152`
logi "Elastic Search docker container name: $${ES_DOCKER_CONTAINER_NAME}, cluster name: $${es_cluster_name}, data volume: $${DOCKER_VOLUME_NAME_ES}, JVM Memory: $${JVM_SIZE}GiB"

logi "ES_CLUSTER_NAMEose file"
# Create the docker-ES_VOL_PATH_DATA
mkdir -p /opt/ot-os
cd /opt/ot-os
curl -s -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker_compose' > compose.yml

logi "execute docker compose up"
docker compose up -d

# Wait for Elastic Search to be yellow
function wait_for_elasticsearch() {
  logi "Waiting for Elastic Search to be ready"
  while ! curl -s http://localhost:9200/_cluster/health?pretty | grep -q '"status" : "yellow"'; do
    sleep 1
  done
  logi "Elastic Search is ready"
}

wait_for_elasticsearch

curl -X DELETE http://localhost:9200/.opensearch-sap-log-types-config
curl -X DELETE http://localhost:9200/.opensearch-sap-pre-packaged-rules-config
curl -X DELETE http://localhost:9200/.plugins-ml-config

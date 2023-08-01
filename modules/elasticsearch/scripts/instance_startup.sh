#!/bin/bash
# Local environment
export path_mount_es_data_volume="/mnt/disks/esdata"
export device_disk_es_data=${GCP_DEVICE_DISK_PREFIX}${DATA_DISK_DEVICE_NAME_ES}
export path_es_data_volume=$${path_mount_es_data_volume}/data
export docker_volume_name_es="esdata"
export docker_image_string_es="opensearchproject/opensearch:latest"
export es_docker_container_name="otp-es"
export es_cluster_name=`hostname`
export es_vol_path_data=$${path_es_data_volume}

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
logi "Prepare data mount point at '$${path_mount_es_data_volume}'"
mkdir -p $${path_mount_es_data_volume}
logi "Mount Elastic Seardh data disk device '$${device_disk_es_data}' at '$${path_mount_es_data_volume}'"
mount $${device_disk_es_data} $${path_mount_es_data_volume}
logi "Create a Docker volume at the Elastic Search Data Volume '$${docker_volume_name_es}' bound to folder '$${path_es_data_volume}'"
docker volume create --name $${docker_volume_name_es} --opt type=none --opt device=$${path_es_data_volume} --opt o=bind
# Launch Elastic Search
logi "Running Elastic Search via Docker, using image $${docker_image_string_es}"
logi "Setting vm.max_map_count to 262144"
sysctl -w vm.max_map_count=262144
# Get machine available memory (KiB)
export MACHINE_SIZE=`cat /proc/meminfo | grep MemTotal | grep -o '[0-9]\+'`
# Use all the machine memory for the JVM minus 1GiB
export JVM_SIZE=`expr $(expr $MACHINE_SIZE / 1048576) - 1`
export JVM_SIZE_HALF=`expr $MACHINE_SIZE / 2097152`
logi "[INFO] Elastic Search docker container name: $${es_docker_container_name}, cluster name: $${es_cluster_name}, data volume: $${docker_volume_name_es}, JVM Memory: $${JVM_SIZE}GiB"
docker run --rm -d \
  --name $${es_docker_container_name} \
  --log-driver=gcplogs \
  -p 9200:9200 \
  -p 9600:9600 \
  -e "path.data=/usr/share/opensearch/data" \
  -e "path.logs=/usr/share/opensearch/logs" \
  -e "cluster.name=$${es_cluster_name}" \
  -e "network.host=0.0.0.0" \
  -e "discovery.type=single-node" \
  -e "bootstrap.memory_lock=true" \
  -e "search.max_open_scroll_context=5000" \
  -e ES_JAVA_OPTS="-Xms$${JVM_SIZE_HALF}g -Xmx$${JVM_SIZE_HALF}g" \
  -v $${docker_volume_name_es}:/usr/share/opensearch/data \
  --ulimit memlock=-1:-1 \
  --ulimit nofile=65536:65536 \
  $${docker_image_string_es}

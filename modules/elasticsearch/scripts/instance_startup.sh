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
export path_mount_es_data_volume="/mnt/disks/esdata"
export device_disk_es_data=${GCP_DEVICE_DISK_PREFIX}${DATA_DISK_DEVICE_NAME_ES}
export path_es_data_volume=$${path_mount_es_data_volume}/data
export docker_volume_name_es="esdata"
export docker_image_string_es="opensearchproject/opensearch:${ELASTIC_SEARCH_VERSION}"
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

# Create the docker-compose file
mkdir -p /opt/ot-os
cat << EOF >> /opt/ot-os/compose.yml
services:
  opensearch:
    iamge: $${docker_image_string_es}
    container_name: $${es_docker_container_name}
    logging:
      driver: gcplogs
    ports:
      - "9200:9200"
      - "9300:9600"
    environment:
      - cluster.name=$${es_cluster_name}
      - network.host=0.0.0.0
      - discovery.type=single-node
      - discovery.seed_hosts=[]
      - bootstrap.memory_lock=true
      - search.max_open_scroll_context=5000
      - OPENSEARCH_JAVA_OPTS=-Xms$${JVM_SIZE_HALF}g -Xmx$${JVM_SIZE_HALF}g
      - DISABLE_SECURITY_PLUGIN=true
    volumes:
      - $${docker_volume_name_es}:/usr/share/opensearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
  elasticsearch_exporter:
    image: quay.io/prometheuscommunity/elasticsearch-exporter:latest
    command:
     - '--es.uri=http://$${es_cluster_name}:9200'
    restart: always
    ports:
    - "127.0.0.1:9114:9114"
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

# docker run --rm -d \
#   --name $${es_docker_container_name} \
#   --log-driver=gcplogs \
#   -p 9200:9200 \
#   -p 9300:9600 \
#   -e "path.data=/usr/share/opensearch/data" \
#   -e "path.logs=/usr/share/opensearch/logs" \
#   -e "cluster.name=$${es_cluster_name}" \
#   -e "network.host=0.0.0.0" \
#   -e "discovery.type=single-node" \
#   -e "discovery.seed_hosts=[]" \
#   -e "bootstrap.memory_lock=true" \
#   -e "search.max_open_scroll_context=5000" \
#   -e OPENSEARCH_JAVA_OPTS="-Xms$${JVM_SIZE_HALF}g -Xmx$${JVM_SIZE_HALF}g" \
#   -e DISABLE_SECURITY_PLUGIN=true \
#   -v $${docker_volume_name_es}:/usr/share/opensearch/data \
#   --ulimit memlock=-1:-1 \
#   --ulimit nofile=65536:65536 \
#   $${docker_image_string_es}


# Wait for Elastic Search to be yellow
function wait_for_elasticsearch() {
  log "[INFO] Waiting for Elastic Search to be ready"
  while ! curl -s http://localhost:9200/_cluster/health?pretty | grep -q '"status" : "yellow"'; do
    sleep 1
  done
  log "[INFO] Elastic Search is ready"
}

wait_for_elasticsearch

curl -X DELETE http://localhost:9200/.opensearch-sap-log-types-config
curl -X DELETE http://localhost:9200/.opensearch-sap-pre-packaged-rules-config
curl -X DELETE http://localhost:9200/.plugins-ml-config

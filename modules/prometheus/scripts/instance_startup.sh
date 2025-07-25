#!/bin/bash
echo "[LAUNCH] Open Targets Prometheus"
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

# Mount prometheus data disk
echo "Mounting Prometheus data disk at /mnt/prometheus-data"
mkdir -p /mnt/prometheus-data

# Check if disk is formatted, format if needed
if ! blkid /dev/disk/by-id/google-prometheus-data; then
    echo "Formatting prometheus data disk..."
    mkfs.ext4 -F /dev/disk/by-id/google-prometheus-data
fi

# Mount the disk
mount -o discard,defaults /dev/disk/by-id/google-prometheus-data /mnt/prometheus-data

# Set correct ownership and permissions for Prometheus
chown -R 65534:65534 /mnt/prometheus-data
chmod 755 /mnt/prometheus-data

# Add to fstab for persistence
echo "/dev/disk/by-id/google-prometheus-data /mnt/prometheus-data ext4 discard,defaults,nofail 0 2" >> /etc/fstab


git clone -b ${git_branch} ${git_repository}

cd terraform-google-opentargets-platform/modules/prometheus/config

mkdir -p /opt/grafana/dashboards

cp datasource.yml /opt/grafana/datasource.yml
cp dashboards.yml /opt/grafana/dashboards.yml

cp -r dashboards/* /opt/grafana/dashboards

mkdir /opt/prometheus

# insert service account key
cat <<EOF > /opt/prometheus/application_default_credentials.json
${svc_acc_key}
EOF

# Start - Create Prometheus config
cat <<EOF > /opt/prometheus/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
EOF

relabling_config='relabel_configs:
      - source_labels: [__meta_gce_instance_name]
        target_label: nodename'

zones=${available_zones}
# Configure scrape configs for api
cat <<EOF >> /opt/prometheus/prometheus.yml
  - job_name: 'api'
    $${relabling_config}
    gce_sd_configs:
EOF
for zone in $(echo $zones | tr "," "\n")
do
cat <<EOF >> /opt/prometheus/prometheus.yml
      - zone: $zone
        project: open-targets-eu-dev
        port: 8080
        filter: (name:${module_wide_prefix_api}*)
EOF
done
# Configure scrape configs for node-exporter
cat <<EOF >> /opt/prometheus/prometheus.yml
  - job_name: 'node'
    $${relabling_config}
    gce_sd_configs:
EOF
for zone in $(echo $zones | tr "," "\n")
do
cat <<EOF >> /opt/prometheus/prometheus.yml
      - zone: $zone
        project: open-targets-eu-dev
        port: 9100
        filter: (name:${instance_prefix}*)
EOF
done
# Configure scrape configs for opensearch-exporter
cat <<EOF >> /opt/prometheus/prometheus.yml
  - job_name: 'opensearch'
    $${relabling_config}
    gce_sd_configs:
EOF
for zone in $(echo $zones | tr "," "\n")
do
cat <<EOF >> /opt/prometheus/prometheus.yml
      - zone: $zone
        project: open-targets-eu-dev
        port: 9114
        filter: (name:${module_wide_prefix_es}*)
EOF
done
# Configure scrape configs for clickhouse-exporter
cat <<EOF >> /opt/prometheus/prometheus.yml
  - job_name: 'clickhouse'
    $${relabling_config}
    gce_sd_configs:
EOF
for zone in $(echo $zones | tr "," "\n")
do
cat <<EOF >> /opt/prometheus/prometheus.yml
      - zone: $zone
        project: open-targets-eu-dev
        port: 9363
        filter: (name:${module_wide_prefix_ch}*)
EOF
done
# Configure scrape configs for prometheus
cat <<EOF >> /opt/prometheus/prometheus.yml
  - job_name: 'prometheus'
    $${relabling_config}
    gce_sd_configs:
EOF
for zone in $(echo $zones | tr "," "\n")
do
cat <<EOF >> /opt/prometheus/prometheus.yml
      - zone: $zone
        project: open-targets-eu-dev
        port: 9090
        filter: (name:${pro_instance_prefix}*)
EOF
done
# End - Create Prometheus config

# Start prometheus and grafana
cd /opt/prometheus

curl -s -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker_compose' | cut -d'"' -f 4 > compose.yml

docker compose up -d
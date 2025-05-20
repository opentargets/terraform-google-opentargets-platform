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

mkdir /opt/prometheus

git clone -b rm-prometheus https://github.com/opentargets/terraform-google-opentargets-platform.git

# copy prometheus config
cp terraform-google-opentargets-platform/modules/prometheus/config/prometheus.yml /opt/prometheus/prometheus.yml

# insert service account key
# echo "svc_acc_key" > /opt/prometheus/application_default_credentials.json
# cat > /etc/example-service-account.json <<EOF
#     svc_acc_key
#     EOF

cat <<EOF > /opt/prometheus/application_default_credentials.json
${svc_acc_key}
EOF

# Start prometheus and grafana
cd terraform-google-opentargets-platform/modules/prometheus/config

docker compose up -d
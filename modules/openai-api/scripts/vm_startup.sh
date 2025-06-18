#!/bin/bash
echo "[LAUNCH] Open Targets Platform OpenAI API"
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
  jq \
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

# Fetch access token
echo "[LAUNCH] Fetching access token to access Secret Manager"
export access_token="$(curl -s -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token' | cut -d'"' -f 4)"
echo "Access token Acquired"

# Fetch secret value from Secret Manager
export secret_response=$(curl -s \
-H "Authorization: Bearer $${access_token}" \
-H "X-Goog-User-Project: ${project_id}" \
"https://secretmanager.googleapis.com/v1/${openai_token}/versions/latest:access")
echo "Secret Response Acquired"

# Parse the secret value from the response JSON using Docker container with jq
secret_value=$(echo $${secret_response} | jq -r .payload.data)
echo "Secret Value parsed"

# Base64-decode the secret value
export secret_value=$(echo $${secret_value} | base64 --decode)
echo "Secret Value decoded"

log "[INFO] Generating compose file"
# Create the docker-compose file
mkdir -p /opt/ot-ai
cd /opt/ot-ai
curl -s -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker_compose' > compose.yml

log "[INFO] execute docker compose up"
docker compose up -d
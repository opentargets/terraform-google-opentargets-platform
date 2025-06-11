#!/bin/bash
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
secret_value=$(echo $${secret_response} | docker run -i --rm backplane/jq -r .payload.data)
echo "Secret Value parsed"

# Base64-decode the secret value
export secret_value=$(echo $${secret_value} | base64 --decode)
echo "Secret Value decoded"

echo "[LAUNCH] Open Targets Platform OpenAI API"
set +x
docker run -d \
    -p ${openai_api_external_port}:${openai_api_internal_port} \
    --name ${openai_api_container_name} \
    --log-driver=gcplogs \
    -e OPENAI_TOKEN=$${secret_value} \
    ${openai_api_docker_image}

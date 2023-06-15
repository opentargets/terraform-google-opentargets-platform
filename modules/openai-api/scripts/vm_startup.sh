echo "[LAUNCH] Open Targets Platform OpenAI API"
set +x
docker run -d \
    -p ${openai_api_external_port}:${openai_api_internal_port} \
    --name ${openai_api_container_name} \
    --log-driver=gcplogs \
    -e OPENAI_TOKEN=$(gcloud secrets versions access latest --secret="${openai_token}") \
    ${openai_api_docker_image}

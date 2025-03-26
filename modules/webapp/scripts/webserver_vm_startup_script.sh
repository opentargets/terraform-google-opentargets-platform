#!/bin/bash


docker run -d \
    --log-driver=gcplogs \
    -p 8080:8080 \
    -e "WEBAPP_API_URL=${webapp_api_url}" \
    -e "WEBAPP_FLAVOR=${webapp_flavor}" \
    -e "WEBAPP_OPENAI_URL=${webapp_ot_ai_api_url}" \
    ghcr.io/opentargets/ot-ui-apps/ot-ui-apps:${webapp_image_tag}
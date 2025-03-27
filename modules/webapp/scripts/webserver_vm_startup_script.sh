#!/bin/bash

docker run -d \
    --log-driver=gcplogs \
    -p 8080:8080 \
    ${env_vars} \
    ghcr.io/opentargets/ot-ui-apps/ot-ui-apps:${webapp_image_version}
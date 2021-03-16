#!/bin/bash
# Startup script for Elastic Search VM Instance

echo "---> [LAUNCH] Open Targets Platform Elastic Search"
# Get machine available memory
export MACHINE_SIZE=`cat /proc/meminfo | grep MemTotal | grep -o '[0-9]\+'`
# Set half the available RAM for the JVM
export JVM_SIZE=`expr $MACHINE_SIZE / 2097152`
# Make sure the image is not in use
docker stop elasticsearch
docker rm elasticsearch
# Launch Elastic Search
docker run -d \
  --name elasticsearch \
  -p 9200:9200 \
  -p 9300:9300 \
  -e discovery.type=single-node \
  -e bootstrap.memory_lock=true \
  -e repositories.url.allowed_urls='https://storage.googleapis.com/*,https://*.amazonaws.com/*' \
  -e thread_pool.write.queue_size=1000 \
  -e cluster.name=`hostname` \
  -e network.host=0.0.0.0 \
  -e search.max_open_scroll_context=5000 \
  -e ES_JAVA_OPTS="-Xms$${JVM_SIZE}g -Xmx$${JVM_SIZE}g" \
  -v esdata:/usr/share/elasticsearch/data \
  -v /var/elasticsearch/cred:/usr/share/elasticsearch/cred \
  -v /var/elasticsearch/log:/var/log/elasticsearch \
  docker.elastic.co/elasticsearch/elasticsearch-oss:${ELASTIC_SEARCH_VERSION}

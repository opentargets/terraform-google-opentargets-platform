#!/bin/bash
# TODO - Clean the script a little bit with environment variables

echo "[DEVOPS] Prepare Web Root"
mkdir -p /srv/site
echo "[DEVOPS] Populate Web Root content from '${deployment_bundle_url}' "
cd /srv
wget --no-check-certificate ${deployment_bundle_url}
cd /srv/site
tar xzvf ../${deployment_bundle_filename}
echo "[DEVOPS] Adjust file permissions"
chown nginx:nginx -R /srv/site
echo "[DEVOPS] Prepare Nginx configuration"
mkdir -p /srv/nginx/conf
cat > /srv/nginx/conf/default.conf <<EOF
server {
    listen 80;

    server_name _;

    root /srv/site;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    access_log /dev/stdout;
    error_log /dev/stdout info;
}
EOF
echo "[START] Nginx web server launching"
docker run -d \
    -p 80:80 \
    -v /srv/site:/srv/site \
    -v /srv/nginx/conf:/etc/nginx/conf.d \
    nginx:${docker_image_version}

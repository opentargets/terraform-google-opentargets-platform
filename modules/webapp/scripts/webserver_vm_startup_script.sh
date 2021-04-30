#!/bin/bash
# Environment
site_folder='/home/site'
nginx_conf_folder='/home/nginx/conf'

# Prepare
echo "[DEVOPS] Prepare Web Root"
mkdir -p $${site_folder}
echo "[DEVOPS] Populate Web Root content from '${deployment_bundle_url}' "
cd $${site_folder}/..
wget --no-check-certificate ${deployment_bundle_url}
cd $${site_folder}
tar xzvf ../${deployment_bundle_filename}
echo "[DEVOPS] Adjust file permissions"
chown nginx:nginx -R /srv/site
echo "[DEVOPS] Prepare Nginx configuration"
mkdir -p $${nginx_conf_folder}
cat > $${nginx_conf_folder}/default.conf <<EOF
server {
    listen 80;

    server_name _;

    root /home/site;
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
    -v $${site_folder}:/srv/site \
    -v $${nginx_conf_folder}:/etc/nginx/conf.d \
    nginx:${docker_image_version}

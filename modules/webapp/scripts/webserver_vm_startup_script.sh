#!/bin/bash
# Environment
export www_data_root="/var/www"
export site_folder="$${www_data_root}/site"
export nginx_conf_folder="$${www_data_root}/nginx/conf"

# Prepare
echo "[DEVOPS] Prepare Web related folders"
mkdir -p $${site_folder}
echo "[DEVOPS] Populate Web Root content from '${deployment_bundle_url}' "
cd $${site_folder}/..
wget --no-check-certificate ${deployment_bundle_url}
cd $${site_folder}
tar xzvf ../${deployment_bundle_filename}
echo "[DEVOPS] Prepare Nginx configuration"
mkdir -p $${nginx_conf_folder}
cat > $${nginx_conf_folder}/default.conf <<'EOF'
server {
    listen 8080;

    server_name _;

    brotli              on;
    brotli_comp_level   11;
    brotli_static       off;
    brotli_types        application/atom+xml application/javascript application/json application/rss+xml application/vnd.ms-fontobject application/x-font-opentype application/x-font-truetype application/x-font-ttf application/x-javascript application/xhtml+xml application/xml font/eot font/opentype font/otf font/truetype image/svg+xml image/vnd.microsoft.icon image/x-icon image/x-win-bitmap text/css text/javascript text/plain text/xml;
    
    keepalive_timeout 650;
    keepalive_requests 10000;

    root /srv/site;
    index index.html;

    location / {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        try_files $uri /index.html =404;
    }

    access_log /dev/stdout;
    error_log /dev/stdout info;
}
EOF
echo "[DEVOPS] Adjust file permissions"
find $${www_data_root} -type d -exec chmod 755 \{} \;
find $${www_data_root} -type f -exec chmod 644 \{} \;
echo "[START] Nginx web server launching"
docker run -d \
    --log-driver=gcplogs \
    -p 8080:8080 \
    -v $${site_folder}:/srv/site \
    -v $${nginx_conf_folder}:/etc/nginx/conf.d \
    macbre/nginx-http3:${docker_image_version}

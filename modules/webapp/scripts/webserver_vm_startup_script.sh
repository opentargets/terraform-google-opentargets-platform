#!/bin/bash
# Environment
www_data_disk_dev = "/dev/sdb"
www_data_dev_mount = "/mnt/disks/wwwdata"
site_folder="$${www_data_dev_mount}/site"
nginx_conf_folder="$${www_data_dev_mount}/nginx/conf"

# Prepare
echo "[BOOTSTRAP] Prepare Web Volume, disk '$${www_data_disk_dev}'"
mkfs.ext4 $${www_data_disk_dev}
mkdir -p $${www_data_dev_mount}
mount $${www_data_disk_dev} $${www_data_dev_mount}
chown nobody:nobody $${www_data_dev_mount}
chmod o+s,g+s $${www_data_dev_mount}
echo "[DEVOPS] Prepare Web related folders"
mkdir -p $${site_folder}
echo "[DEVOPS] Populate Web Root content from '${deployment_bundle_url}' "
cd $${site_folder}/..
wget --no-check-certificate ${deployment_bundle_url}
cd $${site_folder}
tar xzvf ../${deployment_bundle_filename}
echo "[DEVOPS] Prepare Nginx configuration"
mkdir -p $${nginx_conf_folder}
cat > $${nginx_conf_folder}/default.conf <<EOF
server {
    listen 8080;

    server_name _;

    root /srv/site;
    index index.html;

    location / {
        try_files $uri /index.html =404;
    }

    access_log /dev/stdout;
    error_log /dev/stdout info;
}
EOF
echo "[DEVOPS] Adjust file permissions"
#find $${site_folder} -type d -exec chmod 755 \; \{}
#find $${site_folder} -type f -exec chmod 644 \; \{}
find $${www_data_dev_mount} -type d -exec chmod 755 \; \{}
find $${www_data_dev_mount} -type f -exec chmod 644 \; \{}
echo "[START] Nginx web server launching"
docker run -d \
    -p 8080:8080 \
    -v $${site_folder}:/srv/site \
    -v $${nginx_conf_folder}:/etc/nginx/conf.d \
    nginx:${docker_image_version}

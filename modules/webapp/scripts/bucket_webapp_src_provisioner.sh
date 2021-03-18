#!/bin/bash

echo "[START] --- Open Targets Platform Web Application Provisioner ---"
echo "[GIT] Checking out Source code from ${url_repo_webapp} -> ${folder_root_webapp}"
git clone --depth 1 --branch devops ${url_repo_webapp} ${folder_root_webapp}
# TODO - git clone --depth 1 --branch <tag_name> <repo_url>
echo "[BUNDLE] Injecting deployment context in the bundle to be created"
cp ${file_devops_context_template} ${file_devops_context_instance}
for envvar in $( cat ${file_devops_context_instance} | egrep -o "DEVOPS[_A-Z]+$" ); do
    export key=${envvar}
    export value=${!envvar:-undefined}
    echo -e "\t[DEVOPS] Injecting '${key}=${value}'"
    sed -E -i ".bak" "s/${key}(\W|$)/${value};/g" ${file_devops_context_instance}
done
echo -e "\t[DEVOPS] Modifying '${file_indexhtml}'"
sed -i ".bak" -e "/${deployment_context_placeholder}/ {" -e "r ${file_devops_context_instance}" -e "d" -e "}" ${file_indexhtml}
echo "[BUNDLE] Prepare dependencies"
docker run -v ${folder_root_webapp}:/src -v ${build_script}:/build_script.sh node:${docker_node_version} /bin/bash -c "chmod 750 /build_script.sh; /build_script.sh; exit"
echo "[BUCKET] Uploading webapp to bucket"
gsutil cp -r ${folder_webapp_build}/* ${bucket_webapp_url}
echo "[DONE] Process Completed"
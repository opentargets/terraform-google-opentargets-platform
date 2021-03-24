#!/bin/bash

echo "[START] --- Open Targets Platform Web Application Provisioner (Bundle Version) ---"
echo "[PWD] Current directory `pwd`"
mkdir -p ${working_dir}
cd ${working_dir}
echo "[WORKDIR] Working dir at '${working_dir}', cleaning possible previous runs"
rm -rf *
echo "[BUILD] Create build target at '${path_build}'"
mkdir -p ${path_build}
echo "[BUILD] Download bundle from '${url_bundle_download}'"
wget --no-check-certificate "${url_bundle_download}"
cd ${path_build}
echo "[BUILD] Unpack bundle"
tar xzvf "${working_dir}/bundle.tgz"
echo "[BUILD] Attach deployment context at '${file_name_devops_context_instance}'"
cp ${file_name_devops_context_template} ${file_name_devops_context_instance}
for envvar in $( cat ${file_name_devops_context_instance} | egrep -o "DEVOPS[_A-Z]+$" ); do
    export key=${envvar}
    export value=${!envvar:-undefined}
    echo -e "\t[CONTEXT] Injecting '${key}=${value}'"
    sed -E -i ".bak" "s/${key}(\W|$)/${value};/g" ${file_name_devops_context_instance}
done
echo "[CLEAN] Remove context template"
rm -f ${file_name_devops_context_template}
rm -f "${file_name_devops_context_instance}.bak"
echo "[DEPLOY] Uploading webapp to bucket '${bucket_webapp_url}'"
gsutil cp -r `pwd`/* ${bucket_webapp_url}
echo "[DONE] Process Completed ---"

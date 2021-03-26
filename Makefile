# This Makefile helper will set the Terraform Environment and Infrastructure Deployment Context from the given profiles
# Author: Manuel Bernal Llinares <mbdebian@gmail.com>

# --- Use Cases: --- #
## Create a tfenv from its template, format 'tfenv.template.profile', given the 'profile' name and 'destination profile' name
## Activate a tfenv from its template, format 'tfenv.profile', given the 'profile' name
## Activate a deployment context, format 'deployment_context.profile', given the 'profile' name

# Environment
file_name_tfenv_active = tfenv.active
file_name_tfenv_prefix = tfenv
file_name_tfenv_template_prefix = $(file_name_tfenv_prefix).template
file_name_depcontext_active = deployment_context.tfvars
file_name_depcontext_prefix = deployment_context
folder_path_profiles = profiles
file_name_tfbackend_gcp = tfbackend-gcp.template
file_name_tfbackend_active = tfbackend.tf
# Helpers
path_script_replace_with_env_vars_values = helpers/replace_with_env_vars_values.sh

# Default Target --- ##
all:
	@echo "Use this helper to set both Terraform Environment and Infrastructure Deployment Context before actually deploying anything on the Cloud"

# Set which Terraform backend must be used, default is 'local' --- ##
tfbackendremote:
	@echo "[TERRAFORM] Setting Terraform backend to be GCP bucket"
	@cp ${file_name_tfbackend_gcp} ${file_name_tfbackend_active}
	${path_script_replace_with_env_vars_values} ${file_name_tfenv_active} ${file_name_tfbackend_active}
	@echo "[WARNING] You'll need to run 'tfinit' again. Please, make sure you have an active Terraform Environment before that"

tfbackendlocal:
	@echo "[TERRAFORM] Setting Terraform backend to be 'local'"
	@rm -f ${file_name_tfbackend_active}
	@echo "[WARNING] You'll need to run 'tfinit' again. Please, make sure you have an active Terraform Environment before that"

# Create a new Terraform Environment given the baseline template profile --- ##
_tfcreate:
	@echo "[DEBUG] Setting TFState prefix to '${tfstateprefix}'";
	@sed -i ".bak" "s/TF_CONFIG_TFSTATE_PREFIX/${tfstateprefix}/g" ${folder_path_profiles}/${file_name_tfenv_prefix}.${dstprofile}

export tfstateprefix
export dstprofile
tfcreate:
	@echo "[TFENV] Creating Terraform Environment profile '${dstprofile}' from profile '${srcprofile}'"
	@cp ${folder_path_profiles}/${file_name_tfenv_template_prefix}.${srcprofile} ${folder_path_profiles}/${file_name_tfenv_prefix}.${dstprofile}
	@read -p "[INPUT] Prefix for tfstate in the bucket: " tfstateprefix; $(MAKE) _tfcreate

# Activate the given Terraform Environment profile --- ##
tfactivate:
	@echo "[TFENV] Activating Terraform Environment profile '${profile}'"
	@cp ${folder_path_profiles}/${file_name_tfenv_prefix}.${profile} ${file_name_tfenv_active}

# Activate the given Infrastructure Deployment Context profile --- ##
depactivate:
	@echo "[DEPLOYMENT] Activating Infrastructure Deployment Context profile '${profile}'"
	@cp ${folder_path_profiles}/${file_name_depcontext_prefix}.${profile} ${file_name_depcontext_active}

# --- Infrastructure deployment Targets --- ##
# Init --- ##
tfinit:
	@echo "[DEPLOYMENT] Terraform Init for current Terraform Environment and Infrastructure Deployment Context"
	@source ${file_name_tfenv_active} ; \
	terraform init

# Plan --- ##
tfplan:
	@echo "[DEPLOYMENT] Show deployment plan for current Terraform Environment and Infrastructure Deployment Context"
	@source ${file_name_tfenv_active} ; \
	terraform plan --var-file=${file_name_depcontext_active}

# Apply --- ##
tfapply:
	@echo "[DEPLOYMENT] Apply deployment plan for current Terraform Environment and Infrastructure Deployment Context"
	@source ${file_name_tfenv_active} ; \
	terraform apply --var-file=${file_name_depcontext_active}

# Destroy --- ##
tfdestroy:
	@echo "[DEPLOYMENT] Destroy deployment plan for current Terraform Environment and Infrastructure Deployment Context"
	@source ${file_name_tfenv_active} ; \
	terraform destroy --var-file=${file_name_depcontext_active}

# House Keeping --- ##
clean: clean_tfprofile clean_depcontext
	@echo "[HOUSEKEEPING] Cleaning up..."

clean_tfprofile:
	@echo "[HOUSEKEEPING] Cleaning up Terraform Environment active profile"
	@rm -f ${file_name_tfenv_active}

clean_depcontext:
	@echo "[HOUSEKEEPING] Cleaning up Infrastructure Deployment Context active profile"
	@rm -f ${file_name_depcontext_active}

# 'PHONY' targets --- ##
.PHONY: all tfbackendremote tfbackendlocal tfcreate tfactivate depactivate tfinit tfplan tfapply tfdestroy clean clean_tfprofile clean_depcontext _tfcreate
# END --- ##

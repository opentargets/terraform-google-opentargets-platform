# This Makefile helper will set the Terraform Environment and Infrastructure Deployment Context from the given profiles
# Author: Manuel Bernal Llinares <mbdebian@gmail.com>

# Environment
.DEFAULT_GOAL:=help

ROOT_DIR_MAKEFILE_POS:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
file_name_depcontext = deployment_context.auto.tfvars
file_name_depcontext_prefix = deployment_context
folder_path_profiles = profiles
gcp_path_ops_credentials = gs://open-targets-ops/credentials
gcp_filename_ops_credentials_openai = openai-token-ot-platform.txt
local_path_ops_credentials = ${ROOT_DIR_MAKEFILE_POS}/credentials
local_filename_ops_credentials_openai = openai_credentials.txt

# Helpers
path_script_replace_with_env_vars_values = helpers/replace_with_env_vars_values.sh

# Targets --- ##
help: ## show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

status: ## Show the current status of the deployment context
	@echo "[STATUS] Deployment Context Profile: $(shell ls -alh ${file_name_depcontext} | awk '{print $$NF}')"
	@echo "[STATUS] Terraform Workspace: $(shell terraform workspace show)"

tfinit: tmp ## Initialize Terraform
	@echo "[TERRAFORM] Initializing Terraform"
	@terraform init

credentials: ## Collect all the credentials needed for deploying the infrastructure and store them in a local folder
	@mkdir -p ${local_path_ops_credentials}
	@echo "[CREDENTIALS] Collecting credentials at '${local_path_ops_credentials}'"
	@echo "[CREDENTIALS] Collecting OpenAI credentials"
	@gsutil cp ${gcp_path_ops_credentials}/${gcp_filename_ops_credentials_openai} ${local_path_ops_credentials}/${local_filename_ops_credentials_openai}

set_profile: tfinit credentials ## Set the profile to be used for all the operations in the session (use parameter 'profile')
	@echo "[SETUP] Setting profile deployment context profile '${profile}'"
	@ln -sf ${folder_path_profiles}/${file_name_depcontext_prefix}.${profile} ${file_name_depcontext}
	@echo "[SETUP] Switching Terraform Workspace to '${profile}'"
	@terraform workspace select ${profile}
	@make status

update_linked_profile: ## Update a linked deployment context profile to point to a new one, e.g. 'production-platform' -> '23.02', (use parameters 'profile' and 'link_to_profile')
	@echo "[UPDATE] Updating linked deployment context profile '${profile}' to point to '${link_to_profile}'"
	@cd ${folder_path_profiles}; ln -sf ${file_name_depcontext_prefix}.${link_to_profile} ${file_name_depcontext_prefix}.${profile}

clone_profile: ## Clone an existing profile to a new one, starting with an empty workspace (state), and activate the new deployment context profile, as well as its corresponding workspace, use parameters 'profile' and 'new_profile'
	@echo "[CLONE] Cloning profile deployment context profile '${profile}' to '${new_profile}'"
	@cp ${folder_path_profiles}/${file_name_depcontext_prefix}.${profile} ${folder_path_profiles}/${file_name_depcontext_prefix}.${new_profile}
	@echo "[CLONE] Creating Terraform Workspace '${new_profile}'"
	@terraform workspace new ${new_profile}
	@make set_profile profile='${new_profile}'
	@make status

delete_profile: ## Delete an existing profile, use parameter 'profile'
	@echo "[WARNING] Deleting deployment context profile '${profile}'"
	@rm -f ${folder_path_profiles}/${file_name_depcontext_prefix}.${profile}
	@echo "[WARNING] Deleting Terraform Workspace '${profile}'"
	@terraform workspace select ${profile}
	@terraform destroy --auto-approve
	@terraform workspace select default
	@terraform workspace delete ${profile}

tmp: ## Temporary folder for provisioning tasks
	@echo "[SETUP] Creating temporary folder for provisioning tasks"
	@mkdir -p tmp

# House Keeping --- ##
unset_profile: ## Unset the currently active profile
	@echo "[HOUSEKEEPING] Unset Terraform Environment active profile '$(shell ls -alh ${file_name_depcontext} | awk '{print $$NF}')'"
	@rm -f ${file_name_depcontext}
	@echo "[HOUSEKEEPING] Switching Terraform Workspace to 'default'"
	@terraform workspace select default

clean_credentials: ## Clean local credentials
	@echo "[HOUSEKEEPING] Cleaning up local credentials at '${local_path_ops_credentials}'"
	rm -rf ${local_path_ops_credentials}

clean_backend: ## Clean Terraform Backend Cache
	@echo "[HOUSEKEEPING] Cleaning up Terraform Backend Configuration"
	rm -f .terraform/terraform.tfstate

clean: unset_profile clean_backend clean_credentials ## Clean up all the artifacts created by this helper (profile, backend, etc.)
	@echo "[HOUSEKEEPING] Cleaning up..."

# 'PHONY' targets --- ##
.PHONY: set_profile unset_profile clean_backend clean clone_profile delete_profile help status update_linked_profile tfinit clean_credentials
# END --- ##

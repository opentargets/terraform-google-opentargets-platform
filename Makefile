# This Makefile helper will set the Terraform Environment and Infrastructure Deployment Context from the given profiles
# Author: Manuel Bernal Llinares <mbdebian@gmail.com>

# Environment
.DEFAULT_GOAL:=help

ROOT_DIR_MAKEFILE_POS:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
file_name_depcontext = deployment_context.auto.tfvars
file_name_depcontext_prefix = deployment_context
folder_path_profiles = profiles
cicd_folder_path = cicd
cicd_ops_folder_path = $(cicd_folder_path)/ops
cicd_ops_venv_folder_path = $(cicd_ops_folder_path)/.venv
cicd_templates_folder_path = $(cicd_folder_path)/templates
cicd_templates_branch_folder_path = $(cicd_templates_folder_path)/branch
cicd_templates_promote_folder_path = $(cicd_templates_folder_path)/promote
cicd_script_branch_deployment_context = "$(cicd_ops_venv_folder_path)/bin/python $(cicd_ops_folder_path)/branch_deployment_context.py"

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

set_profile: tfinit ## Set the profile to be used for all the operations in the session (use parameter 'profile')
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

# Continuous Deployment
ops_env: ## Create the Python Virtual Environment for the CICD Operations
	@echo "[CICD] Creating Python Virtual Environment for CICD Operations"
	@python -m venv $(cicd_ops_venv_folder_path)
	@echo "[CICD] Installing Python Dependencies for CICD Operations"
	@$(cicd_ops_venv_folder_path)/bin/pip install -r $(cicd_ops_folder_path)/requirements.txt

tf_init: tmp ## Initialize Terraform
	@echo "[CICD] Initializing Terraform"
	@terraform init

spinoff_deployment: ops_env tf_init ## Create a new deployment setup, context and terraform workspace, based on a given deployment source profile and destination profile name, use "source='profile'" and "new='profile'"
	@echo "[CICD] Creating a new deployment context profile based on the source profile '$(source)', new profile name '$(new)'"
	@# TODO Create the new deployment context profile
	@echo "[CICD] Creating a new Terraform Workspace for the new deployment context profile"
	@terraform workspace new $(new)
	@echo "[CICD] Switching Terraform Workspace to the new deployment context profile"
	@terraform workspace select $(new)
	@echo "[CICD] DONE - Creating a new deployment setup '$(new)'"

branch_off_deployment: ## Create a new branch of the respository based on the current branch's deployment context profile, use "new='profile'"
	@echo "TODO"

tmp: ## Temporary folder for provisioning tasks
	@echo "[SETUP] Creating temporary folder for provisioning tasks"
	@mkdir -p tmp

# House Keeping --- ##
unset_profile: ## Unset the currently active profile
	@echo "[HOUSEKEEPING] Unset Terraform Environment active profile '$(shell ls -alh ${file_name_depcontext} | awk '{print $$NF}')'"
	@rm -f ${file_name_depcontext}
	@echo "[HOUSEKEEPING] Switching Terraform Workspace to 'default'"
	@terraform workspace select default

clean_backend: ## Clean Terraform Backend Cache
	@echo "[HOUSEKEEPING] Cleaning up Terraform Backend Configuration"
	rm -f .terraform/terraform.tfstate

clean: unset_profile clean_backend ## Clean up all the artifacts created by this helper (profile, backend, etc.)
	@echo "[HOUSEKEEPING] Cleaning up..."

# 'PHONY' targets --- ##
.PHONY: set_profile unset_profile clean_backend clean clone_profile delete_profile help status update_linked_profile ops_env tf_init branch_deployment
# END --- ##

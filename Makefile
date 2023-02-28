# This Makefile helper will set the Terraform Environment and Infrastructure Deployment Context from the given profiles
# Author: Manuel Bernal Llinares <mbdebian@gmail.com>

# Environment
.DEFAULT_GOAL:=help

ROOT_DIR_MAKEFILE_POS:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
file_name_depcontext = deployment_context.auto.tfvars
file_name_depcontext_prefix = deployment_context
folder_path_profiles = profiles
# Helpers
path_script_replace_with_env_vars_values = helpers/replace_with_env_vars_values.sh

# Targets --- ##
help: ## show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

status: ## Show the current status of the deployment context
	@echo "[STATUS] Deployment Context Profile: $(shell ls -alh ${file_name_depcontext} | awk '{print $$NF}')"
	@echo "[STATUS] Terraform Workspace: $(shell terraform workspace show)"

set_profile: ## Set the profile to be used for all the operations in the session
	@echo "[SETUP] Setting profile deployment context profile '${profile}'"
	@ln -s ${folder_path_profiles}/${file_name_depcontext_prefix}.${profile} ${file_name_depcontext}
	@echo "[SETUP] Switching Terraform Workspace to '${profile}'"
	@terraform workspace select ${profile}

clone_profile: ## Clone an existing profile to a new one, starting with an empty workspace (state)
	@echo "[CLONE] Cloning profile deployment context profile '${profile}' to '${new_profile}'"
	@cp ${folder_path_profiles}/${file_name_depcontext_prefix}.${profile} ${folder_path_profiles}/${file_name_depcontext_prefix}.${new_profile}
	@echo "[CLONE] Creating Terraform Workspace '${new_profile}'"
	@terraform workspace new ${new_profile}

delete_profile: ## Delete an existing profile
	@echo "[WARNING] Deleting deployment context profile '${profile}'"
	@rm -f ${folder_path_profiles}/${file_name_depcontext_prefix}.${profile}
	@echo "[WARNING] Deleting Terraform Workspace '${profile}'"
	@terraform workspace select default
	@terraform workspace delete ${profile}

# House Keeping --- ##
unset_profile: ## Unset the currently active profile
	@echo "[HOUSEKEEPING] Unset Terraform Environment active profile '$(shell ls -alh ${file_name_depcontext} | awk '{print $$NF}')'"
	@rm -f ${file_name_depcontext}
	@echo "[HOUSEKEEPING] Switching Terraform Workspace to 'default'"
	@terraform workspace select default

clean_backend: ## Clean Terraform Backend Cache
	@echo "[HOUSEKEEPING] Cleaning up Terraform Backend Configuration, setting default"
	rm -f .terraform/terraform.tfstate

clean: unset_profile clean_backend ## Clean up all the artifacts created by this helper (profile, backend, etc.)
	@echo "[HOUSEKEEPING] Cleaning up..."

# 'PHONY' targets --- ##
.PHONY: set_profile unset_profile clean_backend clean clone_profile delete_profile help status
# END --- ##

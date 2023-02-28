# This Makefile helper will set the Terraform Environment and Infrastructure Deployment Context from the given profiles
# Author: Manuel Bernal Llinares <mbdebian@gmail.com>

# Environment
file_name_depcontext = deployment_context.auto.tfvars
file_name_depcontext_prefix = deployment_context
folder_path_profiles = profiles
# Helpers
path_script_replace_with_env_vars_values = helpers/replace_with_env_vars_values.sh

# Default Target --- ##
all:
	@echo "Use this helper to set both Terraform Environment and Infrastructure Deployment Context before actually deploying anything on the Cloud"

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
	@echo "[HOUSEKEEPING] Unset Terraform Environment active profile"
	@rm -f ${file_name_depcontext}
	@echo "[HOUSEKEEPING] Switching Terraform Workspace to 'default'"
	@terraform workspace select default

clean_backend: ## Clean Terraform Backend Cache
	@echo "[HOUSEKEEPING] Cleaning up Terraform Backend Configuration, setting default"
	rm -f .terraform/terraform.tfstate

clean: unset_profile clean_backend ## Clean up all the artifacts created by this helper (profile, backend, etc.)
	@echo "[HOUSEKEEPING] Cleaning up..."

# 'PHONY' targets --- ##
.PHONY: all set_profile unset_profile clean_backend clean clone_profile delete_profile
# END --- ##

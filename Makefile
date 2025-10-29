TERRAFORM_DIR := $(CURDIR)/terraform

.PHONY: all init pre-provisioning talos-iso-acquisition vms-provisioning talos-provisioning longhorn-deployment wazuh-certs clean lint

all: init pre-provisioning talos-iso-acquisition vms-provisioning talos-provisioning longhorn-deployment wazuh-certs

lint:
	@echo "Running Terraform format check..."
	terraform fmt -check -recursive
	@echo "Running Terraform validation..."
	terraform validate
	@echo "Running Ansible lint..."
	ansible-lint ansible/playbook.yml

init:
	@echo "Checking for required tools..."
	@MISSING_TOOLS=""; \
	command -v terraform >/dev/null 2>&1 || MISSING_TOOLS="$${MISSING_TOOLS}terraform "; \
	command -v talosctl >/dev/null 2>&1 || MISSING_TOOLS="$${MISSING_TOOLS}talosctl "; \
	command -v jq >/dev/null 2>&1 || MISSING_TOOLS="$${MISSING_TOOLS}jq "; \
	command -v k9s >/dev/null 2>&1 || MISSING_TOOLS="$${MISSING_TOOLS}k9s "; \
	command -v kubectl >/dev/null 2>&1 || MISSING_TOOLS="$${MISSING_TOOLS}kubectl "; \
	if [ -n "$$MISSING_TOOLS" ]; then \
		echo "Missing tools: $$MISSING_TOOLS. Running Ansible playbook to install them..."; \
		ansible-playbook ansible/playbook.yml -K; \
	else \
		echo "All required tools (Terraform, Talosctl, jq, k9s, kubectl) are installed."; \
	fi

pre-provisioning: init
	@echo "Starting NTP and Registry Setup using Docker Compose"
	docker compose -f docker/compose.yml up -d ntp registry
	@echo "NTP server and local container registry are configured."


talos-iso-acquisition: init
	@echo "Starting Talos ISO Acquisition"
	@echo "Reading iso_path from cluster.tfvars..."
	$(eval ISO_PREFIX_PATH_FROM_TFVARS := $(shell grep -oP 'iso_prefix_path = "\K[^"]+' $(TERRAFORM_DIR)/cluster.tfvars))
	@echo "Initializing Terraform modules and providers..."
	terraform -chdir=$(TERRAFORM_DIR) init
	@echo "Executing terraform apply for talos_image_factory..."
	terraform -chdir=$(TERRAFORM_DIR) apply -target=module.talos_image_factory -var-file=cluster.tfvars -auto-approve

vms-provisioning: init
	@echo "Starting VM Creation"
	terraform -chdir=$(TERRAFORM_DIR) apply -target=module.hyperv-host01 -auto-approve -var-file=cluster.tfvars

talos-provisioning: init
	@echo "Starting Talos Provisioning"
	terraform -chdir=$(TERRAFORM_DIR) apply -target=module.talos_cluster -auto-approve -var-file=cluster.tfvars
	@echo "Getting raw kubeconfig from Terraform output..."
	terraform -chdir=$(TERRAFORM_DIR) output -raw kubeconfig > $(TERRAFORM_DIR)/_out/kubeconfig
	@echo "Getting raw talosconfig from Terraform output..."
	terraform -chdir=$(TERRAFORM_DIR) output -raw talosconfig > $(TERRAFORM_DIR)/_out/talosconfig
	@echo "Talos cluster is provisioned and healthy."

longhorn-deployment: init
	@echo "Starting Longhorn Deployment"
	terraform -chdir=$(TERRAFORM_DIR) apply -target=module.longhorn -auto-approve -var-file=cluster.tfvars
	@echo "Longhorn is deployed."

wazuh-certs: init
	@echo "Starting Wazuh Deployment"
	terraform -chdir=$(TERRAFORM_DIR) apply -target=module.wazuh -auto-approve -var-file=cluster.tfvars
	@echo "Wazuh root ca is deployed."

clean:
	@echo "Cleaning up..."
	terraform -chdir=$(TERRAFORM_DIR) destroy -target=module.wazuh -target=module.longhorn -target=module.talos_cluster -target=module.hyperv_host -target=module.talos_image_factory -auto-approve -var-file=cluster.tfvars
	rm -rf $(TERRAFORM_DIR)/_out
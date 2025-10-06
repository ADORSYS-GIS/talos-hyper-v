# talos-hyper-v

This repository contains Terraform configurations and Ansible playbooks to deploy a Talos Kubernetes cluster on Hyper-V.

## Deployment Phases with Ansible

The deployment is orchestrated in three phases using Ansible, with manual verification steps to ensure a robust and controlled process.

### Prerequisites

Before running the Ansible playbook, ensure you have the following:

*   **Terraform:** Installed and configured.
*   **Ansible:** Installed.
*   **Hyper-V Host:** A Windows machine with Hyper-V enabled and WinRM configured for Ansible connectivity.
*   **`cluster.tfvars.example`:** Update this file with your specific Hyper-V host details, VM definitions, and network settings. Rename it to `cluster.tfvars` for Terraform to pick it up.
*   **`talosctl`:** Installed on the machine running Ansible for cluster verification.

### How to Run the Deployment

1.  **Configure Terraform Variables:**
    Rename `terraform/cluster.tfvars.example` to `terraform/cluster.tfvars` and update it with your environment-specific values, especially:
    *   `hyperv_host`: Connection details for your Hyper-V host.
    *   `iso_path`: The path on your Hyper-V host where the Talos ISO will be placed.
    *   `host_vms`: Definitions for your control plane and worker VMs.
    *   `switch`: The name of your Hyper-V virtual switch. Switch must be of type External

2.  **Run the Ansible Deployment Script:**
    Navigate to the `ansible/` directory and execute the `deploy.sh` script:

    ```bash
    cd ansible/
    ./deploy.sh
    ```

    The script will guide you through the three phases:

    #### Phase 1: ISO Acquisition & Verification

    *   Ansible will run Terraform to get the Talos ISO download URL.
    *   You will be prompted to manually download the ISO from the provided URL and place it on your Hyper-V host at the `iso_path` specified in `cluster.tfvars`.
    *   Ansible will then continuously check for the presence and checksum verification of the ISO file before proceeding.

    #### Phase 2: Virtual Machine Creation

    *   Ansible will execute Terraform to create and start the virtual machines on your Hyper-V host.
    *   It will then verify that all defined VMs are in a "Running" state.

    #### Phase 3: Talos Cluster Provisioning

    *   Ansible will perform the final Terraform apply to provision the Talos cluster on the running VMs.
    *   It will then use `talosctl` to verify the cluster's health and ensure all nodes have successfully joined.

This structured approach ensures that each critical step is completed and verified, providing a robust and interactive deployment experience for your Talos Kubernetes cluster on Hyper-V.

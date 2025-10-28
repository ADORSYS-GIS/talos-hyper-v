# talos-hyper-v

This repository contains Terraform configurations and a Makefile to deploy a Talos Kubernetes cluster on Hyper-V.

## Deployment

This deployment is orchestrated using a Makefile, guiding you through the process of setting up a Talos Kubernetes cluster on Hyper-V with manual verification steps.

For detailed instructions on each phase, please refer to the [Provisioning Plan](docs/provisioning_plan.md).

### Prerequisites

Before starting, ensure you have:

*   **Terraform:** Installed and configured.
*   **Talosctl:** Installed on your local machine for cluster verification.
*   **`jq`:** Installed on your local machine for JSON parsing in the Makefile.
*   **k9s:** Installed on your local machine for Kubernetes cluster management.
*   **kubectl:** Installed on your local machine for Kubernetes cluster management.
*   **Hyper-V Host:** A Windows machine with Hyper-V enabled.

### Quick Start

1.  **Configure Terraform Variables:**
    Rename `terraform/cluster.tfvars.example` to `terraform/cluster.tfvars` and update it with your environment-specific values.

2.  **Run the Deployment:**
    Execute `make all` to run the entire deployment process.

    ```bash
    make all
    ```

### Cleanup

To destroy the Terraform-managed infrastructure, execute:

```bash
make clean
```

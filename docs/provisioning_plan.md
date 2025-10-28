# Provisioning Plan for Talos Hyper-V Cluster

This document outlines the steps to deploy a Talos cluster on Hyper-V using the provided Makefile. The deployment is divided into two setup phases and five main deployment phases, all executed directly via Makefile targets.

## Prerequisites

Before starting, ensure you have:
- Terraform installed and accessible in your PATH.
- Talosctl installed and accessible in your PATH.
- `jq` installed and accessible in your PATH.
- `k9s` installed and accessible in your PATH.
- `kubectl` installed and accessible in your PATH.

## Phases of Deployment

The `Makefile` provides targets to execute each phase of the deployment.

**Note on Deployment Strategy:**
> The deployment strategy, which includes manual intervention steps and the use of Terraform partial applies, has been specifically chosen to accommodate limitations within our target infrastructure environment. These limitations include, but are not limited to, the absence of a reliable DHCP service and constraints imposed by low bandwidth. This approach ensures a robust and adaptable deployment process despite environmental challenges.

### 0. Init

This phase checks for the availability of essential tools: Terraform, Talosctl, `jq`, `k9s`, and `kubectl`.

To execute the initialization:
```bash
make init
```

This command verifies that Terraform, Talosctl, `jq`, `k9s`, and `kubectl` are installed and available in your system's PATH. If any are missing, an Ansible playbook will be executed to install them.

### 1. Pre-provisioning

This phase sets up the Network Time Protocol (NTP) server and a local container registry on the Hyper-V host using Docker Compose. The NTP server is crucial for time synchronization across the cluster, and the local registry will be used to store and serve container images for the Talos cluster.

To execute Pre-provisioning:
```bash
make pre-provisioning
```

This command first ensures that utility tools are available (by implicitly calling `make init`), then uses Docker Compose to bring up both the NTP server and the local container registry.

### 2. Talos ISO Acquisition

This phase is responsible for acquiring the necessary Talos ISO image by running Terraform to provision the `talos_image_factory` module. It will prompt the user to download the ISO and place it on the Hyper-V host.

To execute Talos ISO Acquisition:
```bash
make talos-iso-acquisition
```

This command first ensures that utility tools are available (by implicitly calling `make init`), then directly executes Terraform commands to initialize the working directory, apply the `talos_image_factory` module, and retrieve the ISO download URL. It then waits for user confirmation after the ISO is manually placed on the Hyper-V host.

### 3. VM Creation

This phase creates and configures the virtual machines on the Hyper-V host using Terraform. It then verifies that the VMs are running and prompts the user to verify/configure their IP addresses.

To execute VM Creation:
```bash
make vms-provisioning
```

This command first ensures that utility tools are available (by implicitly calling `make init`), then directly executes Terraform to apply the `hyperv-host` modules, creating the virtual machines. It then provides instructions for manual verification of VM status and IP configuration.

### 4. Talos Provisioning

This phase provisions the Talos cluster on the newly created virtual machines using a full Terraform apply. It also extracts and saves the `kubeconfig` and `talosconfig` files.

To execute Talos Provisioning:
```bash
make talos-provisioning
```

This command first ensures that utility tools are available (by implicitly calling `make init`), then performs a full Terraform apply to provision the Talos cluster and outputs the `kubeconfig` and `talosconfig` to the `terraform/_out` directory.

### 5. Longhorn Deployment

This phase deploys Longhorn, a distributed block storage system for Kubernetes, onto the Talos cluster.

To execute Longhorn Deployment:
```bash
make longhorn-deployment
```

This command first ensures that utility tools are available (by implicitly calling `make init`), then executes Terraform to apply the `longhorn` module.

### 6. Wazuh Certificates Deployment

This phase deploys the necessary certificates for Wazuh, a security monitoring platform, onto the Talos cluster.

To execute Wazuh Certificates Deployment:
```bash
make wazuh-certs
```

This command first ensures that utility tools are available (by implicitly calling `make init`), then executes Terraform to apply the `wazuh` module.

## Running All Phases

To execute all phases sequentially:

```bash
make all
```

This command will run `init`, then `pre-provisioning`, then `talos-iso-acquisition`, then `vms-provisioning`, then `talos-provisioning`, then `longhorn-deployment`, and finally `wazuh-certs`.

## Cleanup

The `clean` target is provided to destroy the Terraform-managed infrastructure.

To execute cleanup:
```bash
make clean
```

This command will destroy all resources managed by Terraform, specifically targeting `module.wazuh`, `module.longhorn`, `module.talos_cluster`, `module.hyperv_host`, and `module.talos_image_factory`, and then remove the `terraform/_out` directory.

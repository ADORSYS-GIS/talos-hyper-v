# IaC Provisioning Architecture

This document outlines the architecture and plan for provisioning the Talos cluster using Infrastructure as Code (IaC).

## Architecture Overview

The provisioning process is orchestrated by Ansible, which dynamically generates Terraform configurations to provision Hyper-V virtual machines and then configures them into a Talos cluster.

```mermaid
graph TD
    subgraph Ansible Controller
        A[provision_cluster.yml] --> B{Generates cluster.tfvars};
        B --> C{Runs Terraform};
        C --> D{Parses Terraform Output};
        D --> E{Generates Talos Config};
        E --> F{Applies Talos Config};
        F --> G{Bootstraps Cluster};
    end

    subgraph Hyper-V Hosts
        H[preflight_iso.yml] --> I{Downloads Talos ISO};
        C --> J{Creates VMs via Terraform};
    end

    subgraph Talos Cluster
        G --> K{Control Plane};
        G --> L{Worker Nodes};
    end

    A -- Manages --> H;
    F -- Configures --> K;
    F -- Configures --> L;
```

## Implementation Plan

1.  **Environment Setup**: Ensure Ansible and Terraform are installed and configured correctly.
2.  **Pre-flight Check**: Run the `preflight_iso.yml` playbook to download the Talos ISO on all Hyper-V hosts.
3.  **Cluster Provisioning**: Execute the `provision_cluster.yml` playbook to create the VMs and configure the Talos cluster.
4.  **Cluster Validation**: Verify that the cluster is running and that all nodes are healthy.
5.  **Documentation**: Update the `README.md` with instructions on how to use the IaC provisioning scripts.
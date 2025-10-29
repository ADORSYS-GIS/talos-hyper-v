# Talos Cluster on Hyper-V Architecture

This document outlines the architecture of the Talos Kubernetes cluster deployed on Hyper-V.

## Diagram Description

The diagram should visually represent the following components and their relationships:

*   **Hyper-V Host:** A Windows machine with Hyper-V enabled.
*   **Virtual Switch:** An external virtual switch connecting the VMs to the network.
*   **Control Plane VMs (3):** Three virtual machines running the Talos control plane nodes.
*   **Worker VMs (N):** One or more virtual machines running the Talos worker nodes.
*   **Talos ISO:** The Talos ISO image used to boot the VMs.
*   **Terraform:** The Terraform configuration used to provision the infrastructure.
*   **Makefile:** The Makefile used to orchestrate the deployment process.

The diagram should also illustrate the flow of traffic between the components, such as:

*   Terraform provisioning the VMs on the Hyper-V host.
*   The Talos ISO booting the VMs.
*   The control plane and worker nodes communicating with each other.

## Proposed Diagram

```mermaid
graph LR
    kubectl@{ shape: tag-rect, label: "kubectl" }
    k9s@{ shape: tag-rect, label: "k9s" } 
    talosctl@{ shape: tag-rect, label: "talosctl" }
    terraform@{ shape: procs, label: "terraform"}
    ansible@{ shape: procs, label: "ansible"}
    
    subgraph AdminMachine
        k9s
        kubectl
        talosctl
        terraform
        ansible -- provision --> k9s
        ansible -- provision --> kubectl
        ansible -- provision --> k9s
        ansible -- provision --> talosctl
        ansible -- provision --> terraform
    end
    
    ExternalSwitch1((External Switch))
    ExternalSwitch2((External Switch))

    subgraph Hyper-V-Host-1
        ExternalSwitch1
        VM1(Control Plane 1)
        VM2(Worker 1)
    end
    subgraph Hyper-V-Host-2
        ExternalSwitch2
        VM3(Control Plane 2)
        VM4(Control Plane 3)
        VM5(Worker 2)
    end
    
    VM1 -- Connected to --> ExternalSwitch1
    VM2 -- Connected to --> ExternalSwitch1
    VM3 -- Connected to --> ExternalSwitch2
    VM4 -- Connected to --> ExternalSwitch2
    VM5 -- Connected to --> ExternalSwitch2
    
    subgraph TalosCluster
        Hyper-V-Host-1
        Hyper-V-Host-2
    end
    
    terraform -- Talos ISO (talos-192.168.1.201.iso) --> VM1
    terraform -- Talos ISO (talos-192.168.1.202.iso) --> VM2
    terraform -- Talos ISO (talos-192.168.1.203.iso) --> VM3
    terraform -- Talos ISO (talos-192.168.1.204.iso) --> VM4
    terraform -- Talos ISO (talos-192.168.1.205.iso) --> VM5


    terraform workload@== Longhorn (Storage Class) ==> TalosCluster
    terraform workload@== MetalLB (LoadBalancer) ==> TalosCluster
    terraform workload@== Wazuh certs ==> TalosCluster

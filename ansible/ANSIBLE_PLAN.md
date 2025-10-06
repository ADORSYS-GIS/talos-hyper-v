# Ansible Orchestration Plan for Talos on Hyper-V

This document outlines the design for an Ansible-based orchestration of the Terraform deployment for a Talos cluster on Hyper-V.

## Project Structure

The Ansible project will be structured as follows to ensure modularity and reusability:

```
ansible/
├── playbook.yml
├── roles/
│   ├── phase1_iso_acquisition/
│   │   └── tasks/
│   │       └── main.yml
│   ├── phase2_vm_creation/
│   │   └── tasks/
│   │       └── main.yml
│   └── phase3_talos_provisioning/
│       └── tasks/
│           └── main.yml
└── ansible.cfg
```

## Main Playbook: `playbook.yml`

This will be the main entry point for the Ansible automation.

```yaml
---
- name: Deploy Talos Cluster on Hyper-V
  hosts: localhost
  connection: local
  gather_facts: no

  vars:
    terraform_dir: "{{ playbook_dir }}/../terraform"
    # This path will be dynamically read from the terraform.tfvars file
    iso_path_on_host: "" 

  tasks:
    - name: Phase 1 - Get Talos ISO
      include_role:
        name: phase1_iso_acquisition

    - name: Phase 2 - Create and Start VMs
      include_role:
        name: phase2_vm_creation

    - name: Phase 3 - Provision Talos Cluster
      include_role:
        name: phase3_talos_provisioning
```

## Phase Descriptions

### Phase 1: ISO Acquisition (`phase1_iso_acquisition`)

**Goal:** Obtain the Talos ISO URL from Terraform, prompt the user to download it, and verify its presence and integrity.

**Tasks in `roles/phase1_iso_acquisition/tasks/main.yml`:**
1.  Read the `iso_path` variable from the `cluster.tfvars` file.
2.  Execute `terraform apply -target=module.talos_image_factory` in the `terraform` directory.
3.  Extract the `installer_url` from the Terraform output.
4.  Display a message to the user with the `installer_url` and the expected `iso_path_on_host`.
5.  Use the `ansible.builtin.pause` module to wait for the user to confirm they have downloaded the file.
6.  Check for the file's existence on the Hyper-V host at the specified path.
7.  (Optional) Get the checksum from the Talos image factory output and verify the downloaded file's checksum.

### Phase 2: VM Creation (`phase2_vm_creation`)

**Goal:** Create the virtual machines on the Hyper-V host.

**Tasks in `roles/phase2_vm_creation/tasks/main.yml`:**
1.  Execute `terraform apply -target=module.host1`.
2.  Connect to the Hyper-V host and verify that all VMs specified in `cluster.tfvars` are in a 'Running' state. This can be done with a PowerShell command executed via the `win_shell` module.

### Phase 3: Talos Provisioning (`phase3_talos_provisioning`)

**Goal:** Provision the Talos cluster on the newly created VMs.

**Tasks in `roles/phase3_talos_provisioning/tasks/main.yml`:**
1.  Execute `terraform apply` to run the remaining parts of the configuration, which will apply the Talos configuration.
2.  Use the generated `talosconfig` file to run `talosctl health` and verify the cluster is healthy.
3.  Run `talosctl get members` to ensure all control plane and worker nodes have joined the cluster.

This plan provides a clear roadmap for the implementation. How does this look to you?
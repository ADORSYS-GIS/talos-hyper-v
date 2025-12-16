# BVMAC SIEM Environment Documentation

**Project:** Acquisition et mise en place des équipements SIEM & SOC

**Client:** Bourse des Valeurs Mobilières de l’Afrique Centrale (BVMAC)

**Vendor:** Sky Engineering Professional Sarl (SkyEngPro)

**Version:** 1.0

**Date:** November 2025

## 1. Executive Summary & Project Governance

This document details the technical architecture, deployment logic, and operational parameters of the Security Information and Event Management (SIEM) system deployed for BVMAC. The solution utilizes Wazuh deployed as a highly available Kubernetes cluster on Talos Linux, running atop a Microsoft Hyper-V virtualization stack.

### Project Stakeholders

| Role | Name | Contact |
| :--- | :--- | :--- |
| BVMAC DSI | James NDOUTOUM | ga.ndoutoum@bvmac.cm |
| BVMAC DSI | Thomas ANDA MVE | t.andamve@bvmac.cm |
| BVMAC DSI | Dylane BENGONO | cd.bengono@bvmac.cm |
| SkyEngPro PM| B. Ewang / W. Chieukam | ewang.branda@skyengpro.com |

## 2. Layer I: Machine Layer + VM (Physical & Virtualization)

The foundation of the environment relies on physical bare-metal servers hosting a Microsoft Hyper-V virtualization layer. This layer is responsible for raw compute, memory allocation, and virtual switching.

### 2.1 Hardware Specifications

The cluster is distributed across two physical hosts to ensure resilience.

- **Hyper-V Host 1:** Primary Compute Node (112 GB RAM Pool)
- **Hyper-V Host 2:** Secondary Compute Node (64 GB RAM Pool)

**Total Compute Capacity:** 176 GB RAM available for the cluster.

### 2.2 Virtualization Topology

The environment uses External Virtual Switches to bridge the virtual machines directly to the BVMAC physical network, ensuring low-latency communication for log ingestion.

- **Control Plane Nodes:** 3 Virtual Machines (Distributed across hosts for High Availability).
- **Worker Nodes:** Scalable N Virtual Machines (Hosting the heavy-lifting Wazuh components).

### 2.3 Physical Topology Diagram

![Physical Topology](https://private-us-east-1.manuscdn.com/sessionFile/nnr9AOXzLfC1I99RMnw15J/sandbox/LFC4ubPRaNcA1kws21q4nJ-images_1763642860455_na1fn_L2hvbWUvdWJ1bnR1L3BoeXNpY2FsX3RvcG9sb2d5.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvbm5yOUFPWHpMZkMxSTk5Uk1udzE1Si9zYW5kYm94L0xGQzR1YlBSYU5jQTFrd3MyMXE0bkotaW1hZ2VzXzE3NjM2NDI4NjA0NTVfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwzQm9lWE5wWTJGc1gzUnZjRzlzYjJkNS5wbmciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3OTg3NjE2MDB9fX1dfQ__&Key-Pair-Id=K2HSFNDJXOU9YS&Signature=cXL9rSPsnn8DjtnQ50yowZTYO4c03jf-1MyZRh3Vbl1WdS66MACD0JJkVM0aeETTDVjTVIx6TVTHE~dTB-LG2xaR9SimMM4aFvx9NQqCVF6tOGb6VZ~4yXXEYd1d2smIhNm5~BpYbmhpLQZ3q5FS5pkvbIQ7gs6Hb2weiSz5-moOtlSnfz9Qy9PaqacDSWJsFyRolYsEFlHb8jMnvZ09axzoSnemOsegwN2O-gLL6FKNMQvRqujuoc9T29X4KYGijyZVncLB4fZwPAy7mA6vf4IcmFqM5PWnZsON-EOHBmjWi515JGItjAT3TWEggQIVLuu2Sr1V83KhXtRmmevJOA__)

## 3. Layer II: Infrastructure Provisioning

This layer defines the "Infrastructure as Code" (IaC) methodology used to deploy and maintain the environment. We utilize a dedicated Admin Machine (Controller) that orchestrates the deployment to ensure reproducibility and eliminate manual configuration drift.

### 3.1 The Toolchain

- **Ansible:** Automates the configuration of the Admin Machine itself and initial environment prerequisites.
- **Terraform:** Interacts with the Hyper-V APIs to provision the Virtual Machines, manage ISO attachments, and define network interfaces.
- **Talosctl:** The dedicated CLI for managing the Talos Linux operating system via API (no SSH).
- **Kubectl / k9s:** Standard Kubernetes management tools for the orchestration layer.

### 3.2 Provisioning Workflow

1. **Bootstrap:** Ansible prepares the Admin Station.
2. **Infrastructure:** Terraform requests VM creation from Hyper-V.
3. **OS Load:** VMs boot from the Talos ISO.
4. **Cluster Form:** Talosctl bootstraps the Kubernetes cluster across the nodes.

### 3.3 Provisioning Flow Diagram

![Provisioning Flow](https://private-us-east-1.manuscdn.com/sessionFile/nnr9AOXzLfC1I99RMnw15J/sandbox/LFC4ubPRaNcA1kws21q4nJ-images_1763642860462_na1fn_L2hvbWUvdWJ1bnR1L3Byb3Zpc2lvbmluZ19mbG93.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvbm5yOUFPWHpMZkMxSTk5Uk1udzE1Si9zYW5kYm94L0xGQzR1YlBSYU5jQTFrd3MyMXE0bkotaW1hZ2VzXzE3NjM2NDI4NjA0NjJfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwzQnliM1pwYzJsdmJtbHVaMTltYkc5My5wbmciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3OTg3NjE2MDB9fX1dfQ__&Key-Pair-Id=K2HSFNDJXOU9YS&Signature=erfV0ZTrJ9p6Il36-P7aRY3p-hSmopaiWeMGNBKJ29-dAVU6f~pidaRRlQXlvsynGjWYCgibybT9RoVYa9K8D~d~44~6GQeLVTsxhrxvSwrgkLl71EqOvT-L-BpFRdHX7Z3XbRtlq3W0zL8FqYo1PuqWOU4GSANm6jemQiNu7C2eNBTKf2yLXDJj0rUfrCljEc6GFfmFMoPG-jRHHA6B9b3uYi~oBnu6qvNtW6aVWzXQ-olzEAIbmzNvduexVVpuF667VrvYZ4dxDlmLWnOWuchG5iXO3kUFTESeV-i0TK-06r1XnFqGBsRrle1L1qfJfM2RC6liVemAPHo4OU-SRA__)

## 4. Layer III: Orchestration (Talos & Kubernetes)

To meet the security requirements of a financial institution (BVMAC), we moved away from general-purpose Linux distributions (Ubuntu/CentOS) in favor of Talos Linux.

### 4.1 Operating System: Talos Linux

- **Immutable:** The file system is read-only. Malware cannot persist by modifying system binaries.
- **Minimal Surface:** No SSH, no console, no shell. All access is mutually authenticated via mTLS API.
- **Purpose:** Strictly designed to run Kubernetes.

### 4.2 Container Orchestration: Kubernetes

Kubernetes manages the lifecycle of the Wazuh application containers.

- **Self-Healing:** Automatically restarts Wazuh Manager or Indexer pods if they crash.
- **Load Balancing:** Distributes agent traffic across multiple worker nodes.
- **Storage Orchestration:** Manages the connection between the Indexer pods and the NVMe/Local Path storage.

### 4.3 Cluster Logic Diagram

![Cluster Logic](https://private-us-east-1.manuscdn.com/sessionFile/nnr9AOXzLfC1I99RMnw15J/sandbox/LFC4ubPRaNcA1kws21q4nJ-images_1763642860467_na1fn_L2hvbWUvdWJ1bnR1L2NsdXN0ZXJfbG9naWM.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvbm5yOUFPWHpMZkMxSTk5Uk1udzE1Si9zYW5kYm94L0xGQzR1YlBSYU5jQTFrd3MyMXE0bkotaW1hZ2VzXzE3NjM2NDI4NjA0NjdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyTnNkWE4wWlhKZmJHOW5hV00ucG5nIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzk4NzYxNjAwfX19XX0_&Key-Pair-Id=K2HSFNDJXOU9YS&Signature=Q0u8H8bjk9y3e0ySinKeQKmtzLu-P4D1CJDW9jLpraUvtYZjpXStx94HfIO~LWPmklkG1It~3qZ4nDC4U-JlRuepQdZnTD5vLHkkDgvEYxahSp0NKhl4ptlg2OEwzmxXLyNj9uJbASatzcZ7cSUOKA7PD-CEtk8ezG5qYspd0PeUyDjnohS8vjzaad209wuuJLdwiq~SQwXmmTH5q3ncPPxdHFzD3MLmMBgTDk9tfyQr4u5ZgGVtoMstfSiRMsrZNTcz-ZKapw8dDJbUoDvPj-L803Kl5Owf1xH0HgH9UO9ZzkvqM3d~57-JFNc2Zf58xFVsksjdb6x2jc0EYVZsyA__)

## 5. Layer IV: The Wazuh Cluster (Application Layer)

This is the user-facing layer where the SIEM logic resides. It is configured to meet BVMAC's specific requirements regarding Active Directory integration and reporting.

### 5.1 Components & Data Flow

- **Load Balancer:** The entry point for all Agents.
- **Wazuh Manager (Cluster):** Processes events, decodes logs, and triggers alerts.
- **Wazuh Indexer (Storage):** Highly optimized database (OpenSearch) for log retention. Requires NVMe storage for rapid search.
- **Wazuh Dashboard (UI):** The web interface used by BVMAC analysts.

### 5.2 Specific Configurations (Per BVMAC Questionnaire)

- **Authentication:** Integrated with Active Directory (LDAP).
- **Requirement:** Centralized authentication only (No local accounts for users).

**User Roles (RBAC):**

- **Admin:** System configuration (SkyEngPro / DSI Lead).
- **Analyst:** Incident investigation & Alert management.
- **Auditor:** Read-only access for internal controls (Direction des Contrôles).

**Reporting:**

- **Daily:** Compliance reports for RSSI.
- **Weekly:** Summary for DSI Team.
- **Monthly:** Strategic overview for Management.

**Network Ports:**

- **1514/1515 (TCP):** Agent Communication & Registration.
- **55000 (TCP):** Wazuh API.
- **443 (HTTPS):** Web Dashboard Access.

### 5.3 Application Architecture Diagram

![Application Architecture](https://private-us-east-1.manuscdn.com/sessionFile/nnr9AOXzLfC1I99RMnw15J/sandbox/LFC4ubPRaNcA1kws21q4nJ-images_1763642860470_na1fn_L2hvbWUvdWJ1bnR1L2FwcGxpY2F0aW9uX2FyY2hpdGVjdHVyZQ.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvbm5yOUFPWHpMZkMxSTk5Uk1udzE1Si9zYW5kYm94L0xGQzR1YlBSYU5jQTFrd3MyMXE0bkotaW1hZ2VzXzE3NjM2NDI4NjA0NzBfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyRndjR3hwWTJGMGFXOXVYMkZ5WTJocGRHVmpkSFZ5WlEucG5nIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzk4NzYxNjAwfX19XX0_&Key-Pair-Id=K2HSFNDJXOU9YS&Signature=unemRHW60lROG8HBx4ssSvqsUdGQsw2I4YQWsdALm6KPQtSmqd5TzqO~REmdghgeMUXp-SgBkELoOlOV3CfVdwSNVBroXlo3UVpgOnUa4o7aNJ9aNO837M2bxkIVdS9uitpWTMrWW~Jbwdd90jSEj3YmskzQ7EP86RVV6ypCS7QWgm6lb~TP0KWzyHW0pHgPQNhvDTqGAbNZgAx7aITV24CZGB~EQujhr7vg3H9Os3Zx58kEJZT3Jmt8stFE~frc~7pXOO6QE0pEJCgzhKTj8bXbWnYnGhon564wGJfb2H1NffJNRsAn4eikaa38yp0-dz9OfLVzXzB0ORz3vlP-WA__)

## 6. Disaster Recovery & Maintenance

### 6.1 Data Persistence

- Log data is persisted on local storage volumes mapped to the Hyper-V physical disks.
- **Backup Policy:** Snapshots of the Indexer volumes are taken according to the BVMAC backup schedule.

### 6.2 Maintenance Procedures

- **Node Upgrades:** Carried out via `talosctl upgrade`. This is a non-disruptive rolling update (one node at a time).
- **Scaling:** New worker nodes can be added by simply provisioning a new VM in Terraform and applying the worker configuration.

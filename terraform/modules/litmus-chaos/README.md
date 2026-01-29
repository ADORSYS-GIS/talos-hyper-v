# Litmus Chaos Module

This module installs Litmus Chaos on the Kubernetes cluster.

## Chaos Experiments and Workflows

A pre-configured resilience workflow is provided in `manifests/wazuh-resilience-workflow.yaml`. This workflow includes:
- Pod Delete (with health check probe)
- CPU Hog
- Memory Hog
- Network Loss
- Disk I/O Stress

### Setup Instructions

Before running the chaos workflows, you must ensure the environment is correctly set up with the necessary permissions.

#### 1. Apply Infrastructure Environment
When you set up a new "Infrastructure Environment" in the Litmus dashboard, it provides a YAML manifest to be applied to the cluster. In addition to that, you must ensure the ServiceAccounts referenced in the workflows have `cluster-admin` permissions (or equivalent) to execute experiments.

Apply the provided RBAC manifest:
```bash
kubectl apply -f infra-env-xxxxxx.yaml
```

This creates:
- `argo-chaos` ServiceAccount: Used by the Argo workflow engine to orchestrate the steps.
- `litmus-admin` ServiceAccount: Used by the ChaosEngine to execute the actual experiments in the target namespace.

#### 2. Import the Workflow
1.  Open the Litmus Chaos Center UI.
2.  Navigate to **Workflows** -> **Schedule a workflow**.
3.  Choose **Import YAML**.
4.  Copy and paste the content of `manifests/wazuh-resilience-workflow.yaml`.
5.  Adjust the `appLabel` or `appNamespace` in the workflow parameters if necessary to target different components.
6.  Follow the wizard to schedule or run the workflow.

### Customizing Probes
The `pod-delete` experiment includes a `cmdProbe`. It is currently configured to verify that the Wazuh API port is open:
```yaml
command: "nc -z wazuh-wazuh-helm.wazuh.svc.cluster.local 55000"
```
You can update this command to perform a more thorough check if needed, such as verifying a specific API response.

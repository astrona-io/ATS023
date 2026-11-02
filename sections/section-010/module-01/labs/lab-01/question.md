---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Recover A Stopped Worker Kubelet

Trace a worker readiness failure to its stopped kubelet service and restore it.

## Starting state

The worker kubelet is stopped intentionally. The API server remains available, so node status and host service state can be compared.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-010-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-lab-010-01-01" || exit 1
node_name="astro-ats-023-lab-010-01-01-control-plane"
worker_name="astro-ats-023-lab-010-01-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

The lab deliberately stops the worker kubelet after its fixtures become healthy. Restart that kubelet, leave the worker schedulable and Ready, and record ConfigMap `node-recovery` with component kubelet, the exact worker node name and result ready. Keep all control-plane components running.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.

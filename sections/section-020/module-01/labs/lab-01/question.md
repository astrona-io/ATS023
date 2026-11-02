---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Recover A Controller Manager Static Pod

Repair an invalid controller-manager flag and verify that Deployment reconciliation resumes.

## Starting state

The controller-manager static Pod contains an invalid duration flag and cannot run. Existing application Pods still serve version one. The API server stays reachable.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-020-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-lab-020-01-01" || exit 1
node_name="astro-ats-023-lab-020-01-01-control-plane"
worker_name="astro-ats-023-lab-020-01-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

The worker and API server remain healthy, but the controller manager has an invalid leader-election duration. Inspect its Pod status and previous logs. Restore --leader-elect-lease-duration=15s, keep the API available, then update probe to VERSION=v2 and verify two updated, ready and available replicas. Record controller-recovery with component kube-controller-manager and result restored. A working older replica alone does not prove the controller resumed reconciliation.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.

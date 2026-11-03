---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Troubleshoot Clusters And Nodes Capstone

Solve this question on: `terminal`

This is the capstone for the whole section: one integrated troubleshooting task with no step-by-step guidance.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-capstone-010)"
```

The survey team reserved the worker node of this cluster for its own workloads. The node has the label `pool=survey` and the taint `dedicated=survey:NoSchedule`. After a host incident, the team's two Deployments in `starfleet` do not work.

Restore the service so that:

1. The worker node reports `Ready` and accepts new Pods. Node commands may only target the node containers of this environment, named `astro-ats-023-capstone-010-control-plane` and `astro-ats-023-capstone-010-worker`.

2. The `scout` Deployment has both replicas `Ready` on the worker node.

3. The `probe` Deployment has both replicas `Ready` and uses the image `docker.io/library/busybox:1.37.0`. Its environment variable `LEVEL` must come from the existing ConfigMap `probe-config` through a `configMapKeyRef`.

Constraints: keep the taint and the label on the node, do not cordon it, do not edit the ConfigMap, do not delete the PodDisruptionBudget `probe`, do not delete or scale down a Deployment, and do not replace a reference with a fixed value.

`kubectl` has cluster administrator rights.

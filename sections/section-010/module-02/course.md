---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Pending Pods, Taints And Node Maintenance

A Pod that stays in the `Pending` phase has been accepted by the API server, but no node is running it. The component that picks a node is the scheduler (`kube-scheduler`). When it cannot find one, it records the reason as an event. This module teaches you to read that reason, match it to the rule that caused it, and fix the rule without throwing away the intent behind it.

## Learning goals

After this module you can:

- Explain how the scheduler filters nodes by resource requests, node labels and taints.
- Read a `FailedScheduling` event and name the rule that rejected each node.
- Compare a Pod's requests with a node's allocatable resources.
- Add a toleration or correct a `nodeSelector` instead of removing a taint or a label.
- Cordon, drain and uncordon a node, and explain why a PodDisruptionBudget can stop a drain.

## Before you start

You need Kubernetes basics: Pods, Deployments, namespaces, labels and the commands `kubectl get`, `kubectl describe` and `kubectl apply`. The playground is a `kind` cluster with one control plane node and one worker node. The worker node carries the label `pool=survey`. The `starfleet` namespace contains workloads that run and workloads that stay `Pending` for different reasons.

## Reading order

The first part follows a Pod from creation to node selection and shows what the scheduler checks first: resource requests against allocatable capacity and the `nodeSelector` field. The second part adds taints and tolerations and shows how to repair a placement rule without deleting it. The third part covers node maintenance: cordon, drain, uncordon and the PodDisruptionBudget that can block a drain. A graded lab follows the second part. A summary closes the module.

<!-- astrona:playground -->

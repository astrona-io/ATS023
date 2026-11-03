---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Troubleshoot clusters and nodes

A node stops reporting readiness while some existing containers continue running. A Pod stays in the `Pending` phase although the cluster has free capacity. A Deployment creates Pods that never become ready. Each of these symptoms has more than one possible cause, and each cause leaves evidence in a different place: the node conditions, the scheduler events, the Pod state or the container state.

This section teaches how to read that evidence in order, how to name the component that is responsible, and how to repair the cause without removing the rule or the protection that the owner asked for.

Each module begins with its goals and ends with a summary. Every module has a playground for free practice and a graded lab. A capstone lab at the end of the section combines the three kinds of fault in one cluster, and a knowledge check follows it.

## Learning Outcomes

- Distinguish unready, unschedulable and stale reporting.
- Trace kubelet and runtime dependencies.
- Interpret pressure, trust and connectivity evidence.
- Verify restored node responsibility without undoing intended policy.
- Read a FailedScheduling event and name the rule that rejected each node.
- Add a toleration or correct a nodeSelector instead of removing a taint.
- Cordon, drain and uncordon a node, and explain why a PodDisruptionBudget can stop a drain.
- Tell Pending from ContainerCreating and read Pod phase, container state and events.
- Diagnose ErrImagePull, ImagePullBackOff, CreateContainerConfigError, CrashLoopBackOff, OOMKilled and Evicted.
- Use rollout status, rollout history and rollout undo to repair a failed rollout.

## Modules

The first module, Node Conditions And Host Diagnosis, covers node conditions, leases and the kubelet service, and ends with a lab in which the kubelet of a worker is stopped.

The second module, Pending Pods, Taints And Node Maintenance, covers how the scheduler filters and scores nodes, how taints and tolerations work, and how cordon, drain and disruption budgets behave during maintenance. Its lab repairs a Deployment whose Pod cannot be placed.

The third module, Failed Workloads: Events And Pod States, covers the Pod phase, the container states and the events that explain image, configuration, crash and eviction failures. Its lab repairs a Deployment that fails to start.

The capstone lab combines a stopped kubelet, a Pod that cannot be placed and a Deployment that fails to start, and gives no step list.

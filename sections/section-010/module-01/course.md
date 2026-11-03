---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Node Conditions And Host Diagnosis

A node that stops reporting is one of the first faults an administrator meets. The Node object, its conditions, its Lease and the node controller's taints are the evidence, and the kubelet, the container runtime and the host are the components behind it. This module teaches you to separate an unready node, a stale report and a deliberately cordoned node, and to trace a failure to the component that stopped.

## Learning goals

- Distinguish unready, unschedulable and stale reporting.
- Trace kubelet and runtime dependencies.
- Interpret pressure, trust and connectivity evidence.
- Verify restored node responsibility without undoing intended policy.

## Before you start

You need Kubernetes basics: nodes, Pods, namespaces and the commands `kubectl get` and `kubectl describe`. The playground is a `kind` cluster with one control plane node and one worker node. The kubelet on the worker node is stopped on purpose, so the node reports `NotReady` and you can read every symptom described in the parts.

## Reading order

The first part follows the reporting path from the kubelet to the Node object, the Lease and the taints, and shows how a stale report differs from a failing subsystem. The second part uses the distribution of failures to choose which shared dependency to investigate, and separates node pressure, memory limit kills and storage failures. A graded lab follows the second part, and a guided practice restores the stopped kubelet. A summary closes the module.

<!-- astrona:playground -->

---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Recover A Stopped Worker Kubelet

Trace a worker readiness failure to its stopped kubelet service and restore it.

The task and solution use a separate pinned kind cluster. Run `testing/smoke.sh` with its private kubeconfig to verify initial rejection and reference success. Static validation is not live evidence. Runtime verification remains pending.

**Status: UNTESTED - never run against a live cluster.**

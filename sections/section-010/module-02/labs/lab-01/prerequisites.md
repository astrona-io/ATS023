---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 3 GiB of free memory.
- `kubectl` and `jq`.
- You know how the scheduler filters nodes, what a `FailedScheduling` event says, and how taints, tolerations, `nodeSelector` and resource requests work.

The lab starts a kind cluster (Kubernetes 1.35) with one control plane node and one worker node.

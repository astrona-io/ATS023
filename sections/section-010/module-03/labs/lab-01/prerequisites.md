---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 3 GiB of free memory.
- `kubectl` and `jq`.
- You know how to read Pod states and events, and what `ErrImagePull` and `CreateContainerConfigError` mean.

The lab starts a kind cluster (Kubernetes 1.35) with one control plane node and one worker node.

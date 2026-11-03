---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Prerequisites

- The `astrona` command-line tool, installed and working.
- Podman, because the lab stops and starts the kubelet inside the worker node container of this environment. Node commands may target only the containers of this lab.
- `kubectl` and `jq`, and about 3 GiB of free memory.
- You can read node conditions, scheduling events and Pod states, and you know how taints, tolerations, ConfigMap references and rollouts work.

The lab starts a kind cluster (Kubernetes 1.35) with one control plane node and one worker node.

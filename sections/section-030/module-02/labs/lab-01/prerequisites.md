---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and Python 3.
- You know the path from the kubelet to `kubectl top`, how to read the `v1beta1.metrics.k8s.io` APIService, and how to patch a container argument.

The lab starts a single-node kind cluster (Kubernetes 1.35).

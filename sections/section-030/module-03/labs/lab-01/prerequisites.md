---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and Python 3.
- You know how a memory limit leads to `OOMKilled`, how to read `kubectl describe quota` and a LimitRange, and how to read ReplicaSet events.

The lab starts a single-node kind cluster (Kubernetes 1.35).

# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You can read a container log with `kubectl logs -c` and you know that an init container must finish before the main containers start.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the namespaces `starfleet` and `outpost`. The commands are in the README of this folder.

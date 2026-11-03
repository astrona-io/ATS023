# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know that CoreDNS runs as a Deployment in `kube-system`, that its settings are in the Corefile of a ConfigMap, and how to read a pod's `/etc/resolv.conf`.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads in `starfleet` and `outpost`. The commands for the lab are in the README of this folder.

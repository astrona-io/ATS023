# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq`.
- You know what a Service `targetPort` is, how to read an EndpointSlice, and how a NetworkPolicy selects pods and allows ingress.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads in `starfleet` and `outpost`. The lab needs a network plugin that enforces NetworkPolicy for the deny rule to take effect. The grader checks the NetworkPolicy objects themselves, so the grading result does not depend on the plugin. The commands for the lab are in the README of this folder.

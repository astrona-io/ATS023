# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- Podman (or Docker) with about 3 GiB of free memory. You use it to open a shell on a node container with `podman exec`.
- `kubectl`.
- You know that the kubelet and the container runtime run on each node, and that container logs are files on the node.

The lab starts a kind cluster (Kubernetes 1.35) with one control plane node and one worker node. The node containers are named `astro-ats-023-lab-040-03-01-control-plane` and `astro-ats-023-lab-040-03-01-worker`. The commands are in the README of this folder.

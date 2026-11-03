# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- Podman (or Docker) with about 3 GiB of free memory. You use it to open a shell on a node container.
- `kubectl`.
- You can select a container and a previous instance with `kubectl logs`, you can read a node log under `/var/log/pods`, and you can read the kubelet journal with `journalctl`.

The lab starts a kind cluster (Kubernetes 1.35) with a control plane node and a worker node. The worker container is `astro-ats-023-capstone-040-worker`. The commands are in the README of this folder.

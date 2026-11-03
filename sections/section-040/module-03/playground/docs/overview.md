---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Playground: Node-Level And Component Logs

This environment is ungraded. Nothing is submitted. It is a Kubernetes 1.35 cluster made of two node containers: `astro-ats-023-playground-040-03-control-plane` and `astro-ats-023-playground-040-03-worker`. You reach a node with `podman exec` (or `docker exec`) on its container name.

## What is running

- Pod `beacon-logger` in `starfleet`, pinned to the worker node. It prints a marker line to standard output and a second line to standard error.
- Deployment `scout` in `starfleet`: prints a heartbeat every five seconds.
- Deployment `relay` in `outpost`: its image tag `busybox:1.37.99` does not exist, so its Pod cannot start and the kubelet logs the pull failure.

## What to try

1. On the worker node, list `/var/log/pods` and find the directory of `beacon-logger`. Read the file `logger/0.log` and compare it with `kubectl -n starfleet logs beacon-logger`.
2. List `/var/log/containers` on the worker and see that its entries are links into `/var/log/pods`.
3. Read the kubelet configuration at `/var/lib/kubelet/config.yaml` and look for `containerLogMaxSize` and `containerLogMaxFiles`.
4. Read the kubelet journal on the worker with `journalctl -u kubelet --no-pager` and search it for `busybox:1.37.99`.
5. Run `crictl ps`, `crictl pods` and `crictl logs <container-id>` on the worker.
6. Read the control plane logs with `kubectl -n kube-system logs kube-apiserver-astro-ats-023-playground-040-03-control-plane`, then read the same container with `crictl` on the control plane node.

Remove the environment with `astrona destroy ats-023-playground-040-03`.

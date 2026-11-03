---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Prerequisites

- The `astrona` command-line tool, installed and working.
- Podman and `kubectl`.
- You know that the API server and etcd run as static Pods from `/etc/kubernetes/manifests`, and that `crictl` lists containers on a node.

The lab starts a two-node kind cluster (Kubernetes 1.35) with the Starfleet workloads in `starfleet` and `outpost`. The control-plane node is the container `astro-ats-023-lab-020-02-01-control-plane`. You reach it with `podman exec`.

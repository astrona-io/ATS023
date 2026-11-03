---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Prerequisites

- The `astrona` command-line tool, installed and working.
- Podman and `kubectl`.
- You can read static Pod manifests, `crictl` output and Pod logs, and you know the roles of the API server, etcd, the controller manager, the scheduler and `kube-proxy`.

The lab starts a two-node kind cluster (Kubernetes 1.35). The control-plane node is the container `astro-ats-023-capstone-020-control-plane`. You reach it with `podman exec`.

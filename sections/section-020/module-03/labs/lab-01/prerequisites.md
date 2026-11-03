---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Prerequisites

- The `astrona` command-line tool, installed and working.
- Podman and `kubectl`.
- You know that the scheduler runs as a static Pod from `/etc/kubernetes/manifests`, that it holds the Lease `kube-scheduler`, and how to read a Pod's events.

The lab starts a two-node kind cluster (Kubernetes 1.35) with the Starfleet workloads. The control-plane node is the container `astro-ats-023-lab-020-03-01-control-plane`. You reach it with `podman exec`.

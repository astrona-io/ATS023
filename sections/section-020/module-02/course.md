---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# API Server And etcd Failures

When the API server or etcd fails, `kubectl` itself stops working, so the usual tools cannot help. This module teaches how these two components start from files on the control-plane node, how to read their containers and logs with the container runtime, and how to tell a refused connection from a certificate error and from a permission error.

## Learning Goals

- Explain how the kubelet starts static Pods from `/etc/kubernetes/manifests`.
- Read a component container and its log with `crictl` on the node.
- Name the API server flags for port 6443, certificates and etcd.
- Tell "connection refused", "x509" and "Forbidden" apart.
- Check etcd health with `etcdctl` and the right certificate flags.

## Before You Start

You need basic kubectl skills and a shell with `podman`. The playground is a kind cluster; each node is a container that you reach with `podman exec`. Graded exercises use independent environments and follow the lessons they practise.

## Reading Order

1. Static Pod Manifests And The Kubelet
2. API Server Flags And Error Types
3. etcd Health And Certificates
4. Summary

<!-- astrona:playground -->

---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Node-Level And Component Logs

`kubectl logs` works only while the API server, the kubelet and the Pod object are healthy. When they are not, the evidence is on the node: in log files, in the journal of the kubelet and the container runtime, and in the containers of the control plane. This module shows where a container's output is stored on a node, how the kubelet rotates it, and how to read node services and control plane components when kubectl cannot help.

## Learning Goals

- Describe the path from a container's standard output to the log files under `/var/log/pods` and `/var/log/containers`.
- Name the kubelet settings that rotate container logs and read their values.
- Read the kubelet and container runtime journals with `journalctl`.
- Inspect containers and their logs on a node with `crictl`.
- Read the log of a control plane component with `kubectl` and, when the API server is down, with `crictl`.

## Before You Start

Know what a node, the kubelet and a static Pod are. The playground runs a control plane node and a worker node as containers, and you reach them with `podman exec`. Graded exercises use independent environments and follow the readings they practise.

## Reading Order

1. Where Container Logs Live On The Node: the runtime log format, the two directories and rotation.
2. Reading The Kubelet And Runtime With journalctl And crictl: node services and the runtime's own view.
3. Control Plane Component Logs: static Pod logs through the API and through the runtime.
4. Summary

<!-- astrona:playground -->

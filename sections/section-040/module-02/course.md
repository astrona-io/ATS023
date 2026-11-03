---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Multi-Container Logs And Debug Access

A Pod often runs more than one container: init containers that prepare the Pod, the main application, and helpers that run next to it. Each container has its own output stream, and a failure is visible in only one of them. This module teaches how to choose the right stream, how to read it for one Pod or many, and how to get inside a container when the log is not enough.

## Learning Goals

- Select a container, an init container, a set of Pods and a time window with `kubectl logs`.
- Explain how a sidecar container can stream a log file that the application writes to a shared volume.
- Open a shell in a running container with `kubectl exec`.
- Attach an ephemeral debug container and debug a copy of a Pod with `kubectl debug`.

## Before You Start

Know what a Pod, a container and a namespace are. The playground for this module runs the workloads used in the examples. Graded exercises use independent environments and follow the readings they practise.

## Reading Order

1. Reading Logs Of Containers, Init Containers And Pod Sets: the flags that select the stream, and how to find an init container fault.
2. Sidecar Containers That Stream Log Files: why a file inside a container does not appear in the log, and the pattern that fixes it.
3. Debugging With Exec And Ephemeral Containers: `kubectl exec`, `kubectl debug` on a Pod, a Pod copy and a node.
4. Summary

<!-- astrona:playground -->

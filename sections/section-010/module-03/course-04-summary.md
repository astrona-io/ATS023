---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Summary

A failing workload leaves evidence in three places. The Pod phase is a coarse summary. The container state and last state give a reason, an exit code and a message. The events, written by the scheduler, the kubelet and the controllers, say what happened and when. Read them in that order, and sort events by time so that the newest message is at the end of the list.

The node name splits the problem. A Pod without a node name is waiting for the scheduler. A Pod with a node name is in the hands of the kubelet, which pulls the image, mounts volumes and builds the container's environment. `ContainerCreating` points to the sandbox or to a volume. `ErrImagePull` and `ImagePullBackOff` mean that the image reference, the registry credentials or the network path failed. `CreateContainerConfigError` means that a referenced ConfigMap, Secret or key is missing. A container that never started has no log, so the event message is the evidence.

Containers that start and then fail show a restart pattern. `CrashLoopBackOff` describes the waiting between restarts, and the cause is in the last state and in the previous log. `OOMKilled`, exit code 137, means that the container went over its own memory limit. `Evicted` means that the kubelet removed the whole Pod because the node ran short of a resource. These two have different repairs: a higher limit or a fix in the application, and relief for the node.

A Deployment keeps its history as ReplicaSets. `kubectl rollout status` waits for the result and fails on a timeout. `kubectl rollout undo` returns to an earlier template when that version was good. Whatever the repair, change the single thing that the message names, keep the setting's source of truth in place, and prove the result with ready Pods.

<!-- astrona:playground:destroy -->

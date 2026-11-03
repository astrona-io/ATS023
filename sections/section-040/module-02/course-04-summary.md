---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Summary

A Pod has one log stream per container, and every request for a log names one Pod and one container. The container name, the `--all-containers` flag and the prefix flag decide which stream you read and whether you can tell the lines apart. A label selector reads a set of Pods, and the time and line limits keep the output to the window that matters.

Init containers run before the main containers and must finish with exit code 0. A failing init container blocks the Pod, shows an `Init:` status and writes its own log, which is the first place to look. An application that writes to a file instead of standard output has no container log until a sidecar container prints that file from a shared volume.

When logs are not enough, `kubectl exec` runs a command in a running container, an ephemeral container adds your own tools to a running Pod, a Pod copy lets you change a command without losing the original, and a node debug Pod gives access to the node file system. Each tool adds objects to the cluster, so remove them after the diagnosis.

<!-- astrona:playground:destroy -->

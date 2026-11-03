---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Summary

The container runtime reads the standard output and standard error of each container and writes them to a log file on the node, one line at a time with a time stamp, the stream and a flag for full or partial lines. The kubelet places these files under `/var/log/pods`, one file per restart, and `/var/log/containers` holds links with names that carry the Pod, the namespace and the container.

The kubelet rotates container logs by size and by file count, with defaults of 10Mi and 5 files, and `kubectl logs` reads only the newest file. Older files are available only with node access, and the files of a deleted Pod are removed.

The kubelet and the container runtime are services of the node. Their logs are in the journal, and they explain failures that happen before any container exists, such as an image that cannot be pulled. The `crictl` tool reads the runtime's own list of Pods, containers and logs, and it works when the API server does not.

The control plane components run as static Pods from manifest files on the control plane node. While the API server works, `kubectl -n kube-system logs` reads them. When it does not, the runtime tools read the same containers, and the kubelet journal explains why a static Pod did not start.

<!-- astrona:playground:destroy -->

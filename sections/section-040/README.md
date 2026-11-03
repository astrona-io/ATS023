---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Manage and evaluate container output streams

During a rollout, two `probe` replicas can emit messages from different versions. A Deployment-level log shortcut can show only one selected Pod. Useful log diagnosis starts with an explicit Pod, container and time window, and sometimes with the log files and services on the node itself.

This section has three modules. The first teaches how to select the right container log and how to read exit and restart evidence. The second covers Pods with several containers: init containers, sidecars that stream a log file, and the tools that open a shell or a debug container. The third moves to the node: the log files the runtime writes, the kubelet and containerd journals, `crictl`, and the logs of the control plane components. Each module has an ungraded playground, a graded lab and a summary. The section ends with a capstone and a knowledge check.

## Learning Outcomes

- Explain standard output and supported log retrieval.
- Select container, instance and observation window.
- Interpret restart and termination evidence.
- Protect sensitive records and preserve useful diagnostics.
- Select a container, an init container and a set of Pods with `kubectl logs`, and bound the output with `--since`, `--tail` and `--timestamps`.
- Explain the sidecar pattern for a log file and use `kubectl exec` and `kubectl debug` to inspect a Pod, a Pod copy or a node.
- Find a container log under `/var/log/pods`, explain kubelet log rotation and read the kubelet and containerd journals.
- Read control plane component logs with `kubectl` and with `crictl` when the API server is down.

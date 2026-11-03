---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Summary

The scheduler assigns a node to each Pod that has none. If it finds no node that fits, it records a FailedScheduling event that names the reason. If it is not running at all, new Pods stay Pending with an empty node field and an empty event list. That empty list is the sign that no component looked at the Pod.

The scheduler is a static Pod, so a wrong flag or a missing kubeconfig path keeps it from starting, and the kubelet restarts it in a crash loop. The container log names the rejected flag or file. A running scheduler must also hold the leader election Lease named kube-scheduler. The holder identity names the active instance, and a renew time that keeps moving proves it is alive. Repair means moving a corrected manifest into place and then proving that a new Pod gets a node and that the Lease renews.

Add-ons in kube-system carry the node-level work. kube-proxy runs as a DaemonSet with one Pod per node and a ConfigMap with its configuration and kubeconfig. It turns Services and endpoints into forwarding rules in each node. If it stops, existing rules keep working while new changes are missing. A ConfigMap change needs a restart of the DaemonSet, and a bad DaemonSet change is undone with a rollout undo. DNS and the network plugin follow the same check order: workload, Pods, events, log.

A Service failure is separated from a Pod failure by testing the Pod address, the Service name and the Service address in turn.

<!-- astrona:playground:destroy -->

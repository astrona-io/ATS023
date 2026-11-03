---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Summary

Requests and limits do different jobs. The scheduler places a Pod using the sum of its requests against the allocatable capacity of each node. The kubelet turns requests into CPU weights and limits into kernel settings. The Quality of Service class, calculated from those settings, decides which Pods are stopped first when a node is short of memory.

CPU can be slowed down and memory cannot. A CPU limit throttles a container without an event or a restart. A memory limit makes the kernel end the container process, and the container status records the reason `OOMKilled` and exit code 137. The status `CrashLoopBackOff` is only the waiting period between restarts, so the cause is in the previous state of the container. A higher limit fixes a limit that is too low and does not fix a leak.

A node can refuse Pods while its usage is low, because the scheduler counts requests. Namespace policy acts earlier. The LimitRange adds defaults and bounds, and the ResourceQuota caps the namespace totals, and both are checked when a Pod is created. A rejected Pod never exists, so the evidence is in the events of the ReplicaSet. The right fix changes a value within the policy and does not delete the policy.

<!-- astrona:playground:destroy -->

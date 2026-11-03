---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Summary

A Pod stays `Pending` when the scheduler removes every node in its filter step. The scheduler compares the sum of container requests with the allocatable capacity of each node, matches the `nodeSelector` against node labels and checks taints against tolerations. It records the result as a `FailedScheduling` event that counts the nodes and names the rule that removed each group. Pods in this state have no container, so the Pod description and the events are the only evidence.

Each rule has its own repair. An oversized request is lowered to what the container needs. A `nodeSelector` is corrected to match the real label, or the node receives the missing label. A taint is answered with a toleration on the Pod, which grants permission without opening the node to every workload. A repair that removes the rule hides the original intent and affects other workloads. After each repair, read the event again, because a second rule can still reject the node.

Taints have three effects. `NoSchedule` blocks new Pods only, `PreferNoSchedule` is a soft preference and `NoExecute` also evicts running Pods that do not tolerate it. The node controller adds `not-ready` and `unreachable` taints by itself, and Deployment Pods carry a default toleration of 300 seconds for them.

Cordon marks a node unschedulable, drain evicts its Pods and uncordon returns it to service. The API server enforces PodDisruptionBudgets on evictions, so a drain can wait when a budget allows no disruption. That wait is a protection, not a fault, and the correct answer is to change capacity or the budget with the owner's agreement.

<!-- astrona:playground:destroy -->

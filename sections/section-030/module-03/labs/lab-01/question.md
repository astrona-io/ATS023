---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Question

Solve this question on: `terminal`

Two teams report problems. The `scout` Deployment in `starfleet` keeps restarting, and the `drifter` Deployment in `outpost` has no Pods. Find the causes and fix them without removing any policy.

Requirements:

1. `scout` has two replicas. Both must run and stay `Ready`, and no `scout` container may be `OOMKilled`. The process needs about 150 MiB. Set a memory limit between 192Mi and 256Mi.
2. The ResourceQuota `compute-quota` in `starfleet` must stay in place and keep limiting memory. Change its values if the larger `scout` needs room. Do not change `probe`, which keeps two replicas and a memory limit of 256Mi.
3. `drifter` has two replicas. Both must be `Ready` and each container must have a memory request and a memory limit. The ResourceQuota `outpost-quota` in `outpost` must stay in place and keep limiting memory requests, memory limits and the Pod count.

`kubectl` already points at the cluster as the cluster administrator.

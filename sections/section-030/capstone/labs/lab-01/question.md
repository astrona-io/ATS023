---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Question

Solve this question on: `terminal`

The platform team asks for a usage report for the `starfleet` namespace. Metrics do not work, `scout` keeps restarting, and the `drifter` team in `outpost` has no Pods. Bring the namespaces to a working state and produce the report.

Requirements:

1. `kubectl top nodes` must work. Repair the existing `metrics-server` Deployment in `kube-system`; do not delete or replace it and do not change its image.
2. `scout` in `starfleet` runs two Ready replicas with no `OOMKilled` container. The process needs about 150 MiB, and a container may not have a memory limit above 256Mi. The `probe` Deployment keeps two replicas and its memory limit of 256Mi.
3. `drifter` in `outpost` runs two Ready replicas and every container has a memory request and a memory limit.
4. Both namespace quotas stay in place and keep limiting memory.
5. Create ConfigMap `usage-report` in `starfleet` with `source: metrics.k8s.io/v1beta1` and key `podMetricsJson` holding a current PodMetricsList of the `starfleet` namespace. It must include both `probe` and both `scout` Pods, with CPU and memory usage and timestamps no older than ten minutes.

`kubectl` already points at the cluster as the cluster administrator.

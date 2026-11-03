---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Question

Solve this question on: `terminal`

The `probe` Deployment in `starfleet` runs normally, but `kubectl top nodes` fails with an error about the Metrics API. The HorizontalPodAutoscaler for the cluster cannot read usage either. Repair the metrics pipeline.

Requirements:

1. `kubectl top nodes` must return the usage of the node.
2. The APIService `v1beta1.metrics.k8s.io` must report the condition `Available` as `True`.
3. The Metrics API must return usage for both `probe` Pods in `starfleet`.
4. Repair the existing `metrics-server` Deployment in `kube-system`. Do not delete or replace it, do not change its image and do not change the `probe` Deployment.

The kubelet certificates in this kind cluster are self-signed. `kubectl` already points at the cluster as the cluster administrator.

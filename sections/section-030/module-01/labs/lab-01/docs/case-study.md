---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Starting Environment

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Create ConfigMap `metric-report` with `namespace: starfleet`, `source: metrics.k8s.io/v1beta1` and key `sampleJson` containing a current PodMetricsList response for `starfleet`. The sample must include both ready probe Pods, real CPU and memory usage fields and a timestamp no older than ten minutes. Keep the healthy workload. The metrics API must also be reachable at grading time.

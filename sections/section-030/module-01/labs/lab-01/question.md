---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Capture Live Pod Metrics

Combine ready workload state with a recent metrics API measurement. Use the isolated `starfleet` environment to verify the result.

## Objective

Combine ready workload state with a recent metrics API measurement.

## Starting state

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-030-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-lab-030-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Create ConfigMap `metric-report` with `namespace: starfleet`, `source: metrics.k8s.io/v1beta1` and key `sampleJson` containing a current PodMetricsList response for `starfleet`. The sample must include both ready probe Pods, real CPU and memory usage fields and a timestamp no older than ten minutes. Keep the healthy workload. The metrics API must also be reachable at grading time.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.

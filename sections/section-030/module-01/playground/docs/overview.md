---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Guided Practice: Capture Live Pod Metrics

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-playground-030-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-playground-030-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Inspect the relevant evidence:

```sh
kubectl -n starfleet top pods --containers
kubectl -n starfleet describe deployment probe
```

Resource requests reserve scheduling capacity, while metrics report measured use over a time window. Capture the measurement collection and its timestamp rather than treating requests as usage. A snapshot changes with time, so grading checks recent measurements and workload identities rather than requiring a fixed CPU value.


Apply the required change:

```sh
metric_sample_ready=0
for attempt in $(seq 1 30); do
  metric_sample="$(kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/starfleet/pods)"
  if printf '%s' "$metric_sample" | python3 -c 'import json,sys; items=json.load(sys.stdin).get("items",[]); assert len([item for item in items if item["metadata"]["name"].startswith("probe-")])==2'; then
    metric_sample_ready=1
    break
  fi
  sleep 2
done
test "$metric_sample_ready" -eq 1
kubectl -n starfleet create configmap metric-report --from-literal=namespace=starfleet --from-literal=source=metrics.k8s.io/v1beta1 --from-literal=sampleJson="$metric_sample"
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet get configmap metric-report -o yaml
```

Create ConfigMap `metric-report` with `namespace: starfleet`, `source: metrics.k8s.io/v1beta1` and key `sampleJson` containing a current PodMetricsList response for `starfleet`. The sample must include both ready probe Pods, real CPU and memory usage fields and a timestamp no older than ten minutes. Keep the healthy workload. The metrics API must also be reachable at grading time.


## Common pitfalls

> [!WARNING]
> Requests describe scheduling reservations, not measured use. Capture the timestamp and window with the metrics. A sample can become stale, and the metrics API must remain available.

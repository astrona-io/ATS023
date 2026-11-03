---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Guided Practice: Capture Live Pod Metrics

This practice captures a measurement from the Metrics API and stores it as evidence. The Metrics API is the Kubernetes API group `metrics.k8s.io`, which metrics-server serves. Here you follow the steps with the playground and explain each one.

## Before you start

The playground already runs the `probe` Deployment with two replicas in `starfleet`, the `shuttle` Pod in `starfleet`, the `drifter` Pod in `outpost` and metrics-server. Use a host shell. A kubeconfig is the file that tells `kubectl` which cluster and credentials to use. Select the playground context and confirm it. Every later command depends on this check.

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-playground-030-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-playground-030-01" || exit 1
```

## Inspect the evidence first

Check that the workload is healthy and that `kubectl top` works. The first number to compare is the declared request, and the second is the measurement.

```sh
kubectl -n starfleet top pods --containers
kubectl -n starfleet describe deployment probe
```

The `top` command reads from the Metrics API. The `describe` command reads the Deployment and its events. If `top` reports that the Metrics API is not available, metrics-server has not collected its first samples yet. Wait a short time and run it again.

## Read the raw metrics response

`kubectl get --raw` sends a request to an API path and prints the response without formatting. The path below asks the Metrics API for the metrics of every Pod in `starfleet`. The response is a `PodMetricsList`. Each item has a `timestamp`, a `window` (the length of the averaging period) and a `containers` list with `usage.cpu` and `usage.memory`.

```sh
kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/starfleet/pods
```

Two details matter for the task. The `timestamp` tells you how fresh the sample is. The Pod names in `items` let you confirm that both `probe` replicas were measured.

## Store the sample as a ConfigMap

A ConfigMap is an API object that stores small pieces of configuration data as key and value pairs. The loop below retries for about a minute until both `probe` Pods appear in the response. It then stores the namespace, the API source and the full JSON in a ConfigMap named `metric-report`.

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

The Python one-liner is only a check. It exits with an error when fewer than two items start with `probe-`, and the loop then tries again.

## Compare Pod usage with node usage

Pod metrics are one level of the Metrics API. Node metrics are another. The command below prints the CPU and memory use of each node together with the percentage of the node's allocatable capacity. Run it once and compare it with the sum of the Pod values. The node figure is larger because system components such as the kubelet and the container runtime also use resources.

```sh
kubectl top nodes
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes
```

The raw node response has the same shape as the Pod response: a `timestamp`, a `window` and a `usage` object. The path `/apis/metrics.k8s.io/v1beta1/nodes` returns a `NodeMetricsList`. If this path returns an error while the Pods are healthy, the problem is in the metrics pipeline and not in your application.

## Verify the result

Read the ConfigMap back and compare its `sampleJson` timestamp with the current time. A sample older than ten minutes is stale. Keep the healthy workload as it is, and keep the metrics API reachable.

```sh
kubectl -n starfleet get configmap metric-report -o yaml
```

If the `create` command reports that the ConfigMap already exists, delete it with `kubectl -n starfleet delete configmap metric-report` and create it again with a fresh sample. A ConfigMap does not update itself, so it holds one measurement from one moment.

## What the exercise proved

You compared declarations with a measurement, used the raw Metrics API path and saved a time-stamped sample. The requests of the `probe` Pods describe what the scheduler reserved. The sample describes what the containers used in the last window. Treat the two as separate facts whenever you write a diagnosis.

## Common pitfalls

> [!WARNING]
> Requests describe scheduling reservations, not measured use. Capture the timestamp and the window with the metrics. A sample goes stale, and the Metrics API must still answer when the work is checked.

# Overview: Metrics Server And The Metrics API

This is a playground, not a lab. It has no task and no grading. Start it, try the commands from the reading, break things and start again.

## What is running

- A single-node kind cluster with Kubernetes 1.35. `kubectl` is already set to the playground context `kind-astro-ats-023-playground-030-02`.
- metrics-server in the `kube-system` namespace, installed with the flag `--kubelet-insecure-tls` because kind kubelets use self-signed certificates. The first values appear about a minute after the start.
- The `probe` Deployment in `starfleet` with two replicas. Each replica requests `50m` CPU and `32Mi` memory and has a memory limit of `64Mi`.
- A HorizontalPodAutoscaler named `probe` that keeps the average CPU utilization of the `probe` Pods near 60 percent, with between two and four replicas.

## What to try

- Run `kubectl top nodes` and `kubectl top pods -n starfleet`. Then read the same data with `kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes`.
- Read the kubelet source with `kubectl get --raw "/api/v1/nodes/<node>/proxy/metrics/resource"` and find the memory lines of a `probe` container.
- Print the APIService status with `kubectl get apiservice v1beta1.metrics.k8s.io -o yaml` and find the `Available` condition.
- Read `kubectl -n starfleet get hpa probe` and note the current and target CPU values.
- Scale metrics-server to zero with `kubectl -n kube-system scale deployment metrics-server --replicas=0`. Watch the APIService, `kubectl top` and the HorizontalPodAutoscaler change. Scale it back to one replica and measure how long the data takes to return.
- Remove the argument `--kubelet-insecure-tls` with a JSON patch and read the metrics-server logs. Put the argument back and prove that `kubectl top nodes` works again.

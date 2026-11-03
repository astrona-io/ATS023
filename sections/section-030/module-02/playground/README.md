# Metrics Server And The Metrics API (playground)

Ungraded environment for the module. A single-node kind cluster (Kubernetes 1.35) with metrics-server installed by the astrona `metricsServer` addon, the `probe` Deployment with two replicas in `starfleet` and a HorizontalPodAutoscaler for it.

```sh
astrona run -c .
astrona destroy ats-023-playground-030-02
```

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/workloads.yaml` | Namespace, `probe` Deployment and its HorizontalPodAutoscaler |
| `docs/overview.md` | What is running and what to try |

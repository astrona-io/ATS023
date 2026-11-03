# Requests, Limits, OOM Kills And Quotas (playground)

Ungraded environment for the module. A single-node kind cluster (Kubernetes 1.35) with metrics-server, a ResourceQuota and a LimitRange in `starfleet`, a ResourceQuota in `outpost`, and four workloads with deliberate resource behaviour.

```sh
astrona run -c .
astrona destroy ats-023-playground-030-03
```

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/workloads.yaml` | Namespaces, quotas, LimitRange and the workloads |
| `docs/overview.md` | What is running and what to try |

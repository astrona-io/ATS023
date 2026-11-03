# Scheduler Failures And Cluster Add-Ons Playground

Ungraded two-node kind cluster (Kubernetes 1.35) with the Starfleet workloads: `probe` and `shuttle` in `starfleet`, `drifter` in `outpost`. The control-plane node container is `astro-ats-023-playground-020-03-control-plane`.

## Run it

```sh
astrona run -c .
astrona destroy ats-023-playground-020-03
```

There is no task and no grading. Status: UNTESTED - never run against a live cluster.

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | Namespaces and the Starfleet workloads |
| `docs/overview.md` | What runs and what to try |

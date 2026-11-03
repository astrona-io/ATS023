# Multi-Container Logs And Debug Access - Playground

- **Slug:** ats-023-playground-040-02
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status: UNTESTED - never run against a live cluster.**

A single-node kind cluster (Kubernetes 1.35) with `scout` (two replicas), `bridge` (app plus log-streaming sidecar), `probe` (two containers, one logs an error) and `shuttle` (init container plus main container) in `starfleet`.

```sh
astrona run -c .
astrona destroy ats-023-playground-040-02
```

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | Namespaces and the four workloads |
| `docs/overview.md` | What runs and what to try |

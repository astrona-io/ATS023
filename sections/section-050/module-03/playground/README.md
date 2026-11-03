# Endpoints, Probes And NetworkPolicy - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-023-playground-050-03
- **Type:** Astrona playground - clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35) with a `probe` Deployment (two replicas) and two Services in `starfleet` (one with a wrong `targetPort`), a `shuttle` client in `starfleet` and a `drifter` client in `outpost`. No NetworkPolicy exists. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-023-playground-050-03
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and ideas to try |

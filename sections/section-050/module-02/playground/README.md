# Cluster DNS Troubleshooting - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-023-playground-050-02
- **Type:** Astrona playground - clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35) with the default CoreDNS, a `probe` Deployment and Service and a `shuttle` client in `starfleet`, and a `drifter` client in `outpost`. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-023-playground-050-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and ideas to try |

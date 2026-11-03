# Pending Pods, Taints And Node Maintenance - Playground

- **Slug:** ats-023-playground-010-02
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED - never run against a live cluster.

A kind cluster (Kubernetes 1.35) with one control plane node and one worker node labelled `pool=survey`. In `starfleet`, `scout` and `bridge` run, `probe` stays `Pending` because of a wrong `nodeSelector`, and `shuttle` stays `Pending` because it requests 64 CPUs. A PodDisruptionBudget on `bridge` allows no disruption. `outpost` runs `drifter`.

## Run it

```sh
astrona run -c .
astrona destroy ats-023-playground-010-02
```

There is no `astrona submit`: the environment has no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/setup.sh` | Context guard, labels the worker, applies the workloads |
| `bootstrap/workloads.yaml` | Namespaces, Deployments and the PodDisruptionBudget |
| `docs/overview.md` | What runs and what to try |

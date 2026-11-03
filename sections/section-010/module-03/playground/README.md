# Failed Workloads: Events And Pod States - Playground

- **Slug:** ats-023-playground-010-03
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED - never run against a live cluster.

A kind cluster (Kubernetes 1.35) with one control plane node and one worker node. In `starfleet`, `probe` runs, `scout` has a bad image tag in its second revision, `shuttle` refers to a missing ConfigMap, `bridge` refers to a missing key, and the Pod `wait-volume` mounts a missing ConfigMap volume. In `outpost`, `drifter` allocates more memory than its limit.

## Run it

```sh
astrona run -c .
astrona destroy ats-023-playground-010-03
```

There is no `astrona submit`: the environment has no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/setup.sh` | Context guard, applies the workloads, sets the bad image on `scout` |
| `bootstrap/workloads.yaml` | Namespaces, ConfigMaps, Deployments and the Pod `wait-volume` |
| `docs/overview.md` | What runs and what to try |

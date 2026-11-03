# Node-Level And Component Logs - Playground

- **Slug:** ats-023-playground-040-03
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status: UNTESTED - never run against a live cluster.**

A kind cluster (Kubernetes 1.35) with one control plane node and one worker node. Pod `beacon-logger` runs on the worker, Deployment `scout` prints heartbeats, and Deployment `relay` has a missing image tag so the kubelet journal contains pull errors.

```sh
astrona run -c .
astrona destroy ats-023-playground-040-03
```

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (one worker node) |
| `bootstrap/setup.sh` | Context guard, applies the manifest, bounded waits |
| `bootstrap/manifests/start.yaml` | Namespaces and workloads |
| `docs/overview.md` | What runs and what to try |

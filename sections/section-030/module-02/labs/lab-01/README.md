---
estimated_duration: 20m
---

# Lab: Repair metrics-server

Graded lab for the metrics module. The astrona addon installs metrics-server. The seed script then removes its argument `--kubelet-insecure-tls`, so it cannot scrape the self-signed kubelet certificates and `kubectl top` fails. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-023-lab-030-02-01
```

Authors prove the reference solution with `astrona test -c .`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-top-nodes-works.sh` | `kubectl top nodes` returns data within two minutes |
| `validate-apiservice-available.sh` | The APIService `v1beta1.metrics.k8s.io` has `Available=True` |
| `validate-pod-metrics-served.sh` | The Metrics API returns both `probe` Pods in `starfleet` |
| `validate-metrics-server-intact.sh` | The seeded Deployment was edited, not replaced; the image is unchanged; the argument appears once; a replica is ready |

The fault depends on the addon's Deployment being named `metrics-server` in `kube-system` and on its argument list containing `--kubelet-insecure-tls`; both are assumptions that the first live run must confirm.

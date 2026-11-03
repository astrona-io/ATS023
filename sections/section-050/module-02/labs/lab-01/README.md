---
estimated_duration: 20m
---

# Lab: Repair Cluster DNS

Graded lab for the cluster DNS module. CoreDNS starts scaled to zero and its Corefile names a cluster domain that does not exist. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/module-02/labs/lab-01
astrona destroy ats-023-lab-050-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-coredns-running.sh` | The `coredns` Deployment has 2 replicas and both are ready |
| `validate-corefile-zone.sh` | The `kubernetes` plugin serves `cluster.local`; `forward` and `errors` remain |
| `validate-service-lookups.sh` | `nslookup` of the Service FQDN works from `starfleet` and `outpost`; the short name works with `wget` |
| `validate-dns-not-bypassed.sh` | Pods still use the `kube-dns` Service address; no `dnsPolicy` or `dnsConfig` override; `probe` unchanged |

Before any change, all four checks fail.

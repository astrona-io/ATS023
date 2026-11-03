---
estimated_duration: 30m
---

# Capstone: Repair Metrics, Fix A Kill And A Rejection, Report Usage

Integrated, unguided task for the whole section. metrics-server cannot scrape the kubelets, `scout` is `OOMKilled` and the quota has no room for the fix, `drifter` is rejected by a quota with no defaults, and a usage report is needed. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-023-capstone-030
```

Authors prove the reference solution with `astrona test -c .`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-top-nodes-works.sh` | `kubectl top nodes` returns data |
| `validate-metrics-server-intact.sh` | metrics-server was repaired in place, with the argument once and a ready replica |
| `validate-scout-not-oomkilled.sh` | `scout` has a limit of 192Mi to 256Mi, 2 ready replicas and no `OOMKilled` container |
| `validate-starfleet-quota-and-probe-intact.sh` | `compute-quota` still limits memory and `probe` is unchanged |
| `validate-drifter-admitted.sh` | `drifter` has 2 ready replicas with memory requests and limits |
| `validate-outpost-quota-intact.sh` | `outpost-quota` still limits memory and Pods |
| `validate-usage-report.sh` | `usage-report` has a recent PodMetricsList with 2 `probe` and 2 `scout` Pods |

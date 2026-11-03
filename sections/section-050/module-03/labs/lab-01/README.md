---
estimated_duration: 25m
---

# Lab: Repair A Service Port And A Deny Policy

Graded lab for the endpoints and NetworkPolicy module. The `probe` Service forwards to the wrong port, and a default-deny policy blocks every client. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/module-03/labs/lab-01
astrona destroy ats-023-lab-050-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`. The checks need `jq` on the host.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-service-endpoints.sh` | EndpointSlices of `probe` hold 2 ready endpoints on port 8080 |
| `validate-shuttle-reaches-probe.sh` | A real `wget` from `shuttle` to `http://probe/` returns `version=v1` |
| `validate-allow-policy.sh` | A NetworkPolicy allows `app=shuttle` to `app=probe` on TCP 8080 |
| `validate-isolation-kept.sh` | The probe pods are still selected by an Ingress policy and no rule allows every source |
| `validate-workloads-unchanged.sh` | `probe` has 2 replicas, the Service is ClusterIP on port 80, `shuttle` and `drifter` exist |

`validate-isolation-kept.sh` and `validate-workloads-unchanged.sh` pass before any change. The other three fail. The live request check passes after the fix only if the network plugin lets the allowed traffic through; it fails at the start because of the port fault whether or not the plugin enforces policies.

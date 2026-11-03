---
estimated_duration: 30m
---

# Capstone: Troubleshoot Services And Networking

Integrated, unguided capstone for the section. Four faults sit on one request path: CoreDNS is scaled to zero, the `probe` readiness probe checks the wrong port, the `scout` Service selector matches no pod, and the allow policy names the Service port instead of the pod port. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/capstone/labs/lab-01
astrona destroy ats-023-capstone-050
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`. The checks need `jq` on the host.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-coredns-ready.sh` | `coredns` has 2 replicas and they are ready |
| `validate-probe-endpoints.sh` | `probe` has 2 ready endpoints and a readiness probe on its container port |
| `validate-scout-endpoints.sh` | `scout` has 2 ready endpoints and the Deployment is unchanged |
| `validate-dns-lookups.sh` | `nslookup` of both Service FQDNs returns the cluster IPs from `shuttle` |
| `validate-shuttle-reaches-both.sh` | `wget` from `shuttle` to both Services returns `version=v1` |
| `validate-policy-allows-shuttle-only.sh` | Policies allow `shuttle` on TCP 8080 to both apps; the default deny remains; no open rule |

All six checks fail before any change.

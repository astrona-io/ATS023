---
estimated_duration: 25m
---

# Lab: Recover An API Server With A Wrong etcd Address

**Status: UNTESTED - never run against a live cluster.**

Graded lab for the API server and etcd module. The API server manifest has a wrong etcd port, so `kubectl` fails. The learner repairs it on the node with `podman exec`. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-023-lab-020-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-etcd-flag-restored.sh` | One `--etcd-servers=https://127.0.0.1:2379` flag, no `2399`, and no extra files in the manifest directory |
| `validate-apiserver-ready.sh` | `/readyz` answers `ok` (retries up to 3 minutes) and the container runs |
| `validate-etcd-healthy.sh` | The etcd manifest is unchanged, `etcdctl endpoint health` is healthy and `/readyz/etcd` is `ok` |
| `validate-recovery-record.sh` | The ConfigMap `apiserver-recovery` has `flag` and `etcd-client-port` |
| `validate-workloads-intact.sh` | `probe` has two available replicas, `shuttle` runs and the API accepts a write |

`etcd-healthy` passes on the start state, because etcd is not broken. It fails if the learner edits the etcd manifest. All other checks fail on the start state.

---
estimated_duration: 30m
---

# Capstone: Troubleshoot Cluster Components

**Status: UNTESTED - never run against a live cluster.**

Graded integration lab for the whole section. Four faults start together: a wrong etcd port in the API server manifest, an invalid flag in the controller manager manifest, a missing kubeconfig path in the scheduler manifest and a missing image tag in the `kube-proxy` DaemonSet. The task is in `question.md`; the order that works is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-023-capstone-020
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-apiserver-etcd-address.sh` | `--etcd-servers` uses port 2379 and `/readyz` is `ok` (retries) |
| `validate-controller-manager-flag.sh` | The invalid flag is gone, leader election stays on and the Pod is Ready |
| `validate-scheduler-kubeconfig.sh` | The kubeconfig flag is correct, the Pod is Ready and the Lease renews |
| `validate-kube-proxy-daemonset.sh` | Two Ready `kube-proxy` Pods, the original image and the ConfigMap kept |
| `validate-scout-running.sh` | `scout` has two available replicas owned by a ReplicaSet, with no `nodeName` |
| `validate-service-and-manifests.sh` | `shuttle` reaches `probe`, `drifter` runs, the etcd manifest is unchanged and the manifest directory holds four files |

All checks fail on the start state.

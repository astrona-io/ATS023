---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Crashes, Evictions And Rollbacks

Some Pods start without a problem and fail later. The container exits, the container runs out of memory, or the kubelet removes the whole Pod to protect the node. Each case leaves a different mark on the Pod. This part shows how to recognise the marks and how to use the Deployment's rollout history to return to a version that worked.

## Crashing containers

When a container exits and the Pod's `restartPolicy` is `Always` (the default for Pods that a Deployment creates), the kubelet restarts it. If the container keeps failing, the kubelet waits longer between restarts, up to five minutes. During the wait, the state is `Waiting` with the reason `CrashLoopBackOff`. The word describes the restart pattern. It does not say why the container exits.

The cause is in the previous run. Read the last state and the log of the container that terminated:

<!-- astrona:playground:renew -->

```sh
kubectl -n outpost get pods
kubectl -n outpost describe pod -l app=drifter
kubectl -n outpost logs -l app=drifter --previous
```

The `describe` output shows `Last State: Terminated` with a reason, an exit code and the start and finish times. Exit code 1 is a general application error. Exit code 137 means that the process received `SIGKILL`, which is how the kernel stops a container that exceeds its memory limit. The `--previous` flag prints the log of the earlier container run, which holds the application's own error message, if it wrote one.

## Reading exit codes

The exit code in the last state is a quick clue. Code 0 means that the process finished normally. In a Deployment that is still a fault, because the kubelet restarts a container that ends and the workload should run continuously. Code 1 or another small number is an error that the application chose. Codes above 128 mean a signal: 137 is `SIGKILL` (128 plus 9), often an out-of-memory kill, and 143 is `SIGTERM` (128 plus 15), a normal stop request. Pair the code with the reason field and the previous log to separate an application bug from a limit set too low.

## Out-of-memory kills

A container with a memory limit may use at most that amount. When it goes over, the Linux kernel's out-of-memory killer ends the process, and the container's last state shows the reason `OOMKilled`. The `drifter` Pod in the playground allocates more memory than its limit of 64 MiB, so it fails again and again.

This is a decision about the container boundary, and the node is not under pressure. The repair is to raise the memory limit to what the application needs, or to fix the application's memory use. It is not to restart the Pod or to move it to another node. Check the limit:

```sh
kubectl -n outpost get deployment drifter -o jsonpath='{.spec.template.spec.containers[0].resources}'
```

The command prints the requests and limits. Compare the limit with the memory that the application needs, which you know from its documentation or its metrics.

## Evicted Pods

An evicted Pod is different. The kubelet monitors the node's memory, disk and process IDs. When a resource falls below its eviction threshold, the kubelet stops one or more Pods to recover the resource. It sets the Pod's phase to `Failed` with the reason `Evicted`, and the message says which resource was short, for example that the node was low on memory or ephemeral storage. The Pod object stays in the API until someone deletes it, so `kubectl get pods` lists it with the status `Evicted`.

A Deployment replaces an evicted Pod with a new one. The new Pod needs a node with enough free resources, so it may stay `Pending`. Check the node first: `kubectl describe node` shows the `MemoryPressure` and `DiskPressure` conditions. Deleting old evicted Pods cleans the list but does not fix the shortage. A Pod's own memory limit kill and a node eviction are not the same event: the first is `OOMKilled` on a container, the second is `Evicted` on a Pod.

List the failed Pods of the whole cluster with a field selector on the phase:

```sh
kubectl get pods -A --field-selector status.phase=Failed
```

The output lists every Pod that ended in the `Failed` phase, including evicted ones. The playground has none, because its node has no pressure, so an empty result is the expected answer. In a real cluster, the `describe` output of such a Pod shows the `Reason: Evicted` line and a message that names the resource. The `kubectl delete pod` command removes the leftover object after you have read it.

## Rollouts, history and undo

A Deployment keeps a ReplicaSet for each version of its Pod template. A rolling update creates Pods of the new version and removes Pods of the old version step by step, while it keeps the number of available Pods within `maxUnavailable` and `maxSurge`. If the new Pods never become ready, the rollout stops, and the old Pods keep serving. The Deployment then has `Progressing` set to `False` after its progress deadline of 600 seconds.

Use `rollout status` to wait for the result and `rollout history` to list the versions:

```sh
kubectl -n starfleet rollout status deployment/scout --timeout=30s
kubectl -n starfleet rollout history deployment/scout
```

`rollout status` exits with a non-zero code when the rollout does not finish before the timeout, so it can gate a script. The history lists the revisions with numbers. The command `kubectl rollout undo` returns the Deployment to the previous revision, and `--to-revision=2` selects a specific one.

```sh
kubectl -n starfleet rollout undo deployment/scout
```

Check which revision is good before you undo. If you already repaired `scout` with `kubectl set image`, the newest revision is the good one, and undo would return to the failing revision. Print the template of a revision with `kubectl -n starfleet rollout history deployment/scout --revision=2` and compare its image. Undo copies the Pod template of the earlier ReplicaSet into the Deployment. It is the fastest repair when the last change broke the workload and the earlier version was good. It cannot help when no earlier revision exists, or when the earlier revision is also broken. Undo changes the template, so it creates a new revision number; the history does not go backwards.

## A rollout that stalls

A rollout can also stall without a crash. Suppose the new Pods start, but their readiness probe fails. The Deployment controller counts a Pod as available only after it is ready for `minReadySeconds`. With the default `maxUnavailable` of 25 percent and `maxSurge` of 25 percent, a Deployment of four replicas removes one old Pod and adds one new Pod. If the new Pod never becomes ready, the controller does not remove more old Pods. Users still reach the old Pods, and `rollout status` waits until its timeout.

The Deployment's conditions show this state. `Available` stays `True` because enough old Pods serve, and `Progressing` changes to `False` with the reason `ProgressDeadlineExceeded` after the progress deadline. Read them with `kubectl describe deployment`. The Pod-level cause is still in the new Pods' events and states, so follow the chain from the Deployment to its newest ReplicaSet and then to that ReplicaSet's Pods.

```sh
kubectl -n starfleet get replicaset -l app=scout
```

The command lists the ReplicaSets of `scout`. The newest one has the `DESIRED` count but a lower `READY` count, and the older one still has ready Pods. The numbers show how far the rollout got.

The rule for a good repair is the same in each case. Identify the state, find the message that names the cause and change the one thing that the message points to. Verify with `rollout status` and with the Pod list, and keep the evidence of the first failure until the repair is proven.

This part showed how crashes, memory kills and evictions leave different marks and how a rollout gives a way back. In every case, read the state, the last state and the events before you act.

## Common pitfalls

> [!WARNING]
> `CrashLoopBackOff` is a restart pattern, not a cause: read the last state and the previous log. `OOMKilled` points to the container's memory limit, while `Evicted` points to node pressure. Do not delete evicted Pods and assume the problem is gone. `rollout undo` helps only when an earlier good revision exists, and it does not fix a bad ConfigMap that both revisions use.

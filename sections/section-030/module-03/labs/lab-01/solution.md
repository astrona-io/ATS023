---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running, and select its kubeconfig:

```sh
astrona run -c .
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-030-03-01)"
```

## Step 1: Prove the OOM kill

```sh
kubectl -n starfleet get pods -l app=scout
kubectl -n starfleet get pod -l app=scout -o jsonpath='{.items[0].status.containerStatuses[0].lastState.terminated.reason}{" "}{.items[0].status.containerStatuses[0].lastState.terminated.exitCode}{"\n"}'
```

The restart count rises. The previous state of the container has the reason `OOMKilled` and exit code `137`. The memory limit is 96Mi and the process needs about 150Mi.

## Step 2: Make room in the quota, then raise the limit

Read the quota and the LimitRange first:

```sh
kubectl -n starfleet describe quota compute-quota
kubectl -n starfleet get limitrange container-limits -o yaml
```

`probe` uses 512Mi of the memory limit total. A `scout` limit of 200Mi for two replicas adds 400Mi, which is above the cap of 768Mi. The LimitRange allows at most 256Mi per container, so 200Mi is allowed. Raise the quota, then the limit:

```sh
kubectl -n starfleet patch resourcequota compute-quota --type=merge -p '{"spec":{"hard":{"limits.memory":"1Gi"}}}'
kubectl -n starfleet set resources deployment/scout --limits=memory=200Mi
kubectl -n starfleet rollout status deployment/scout --timeout=180s
```

Grade it:

```sh
astrona submit -c . --keep
```

The checks `scout-not-oomkilled` and `starfleet-quota-and-probe-intact` pass.

## Step 3: Find why drifter has no Pods

```sh
kubectl -n outpost get deployment drifter
kubectl -n outpost describe replicaset -l app=drifter | grep -A3 FailedCreate
kubectl -n outpost describe quota outpost-quota
```

The events say that the quota requires a limit and a request for memory and the Pod sets none. `outpost` has no LimitRange, so nothing fills them in.

## Step 4: Add defaults with a LimitRange

Save this as `limitrange-outpost.yaml`:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: container-defaults
  namespace: outpost
spec:
  limits:
  - type: Container
    default:
      memory: 64Mi
    defaultRequest:
      memory: 32Mi
```

Apply it:

```sh
kubectl apply -f limitrange-outpost.yaml
```

Then restart the Deployment so the ReplicaSet retries now, and check the result:

```sh
kubectl -n outpost rollout restart deployment/drifter
kubectl -n outpost rollout status deployment/drifter --timeout=180s
kubectl -n outpost describe quota outpost-quota
```

Two replicas use 64Mi of requests and 128Mi of limits, which fits the quota. Setting resources in the Deployment with `kubectl set resources` is also a correct fix.

```sh
astrona submit -c .
```

All four checks pass. Remove the lab with `astrona destroy ats-023-lab-030-03-01`.

## Common pitfalls

> [!WARNING]
> Do not delete a quota to make Pods start. A limit above the LimitRange maximum is rejected. A LimitRange does not change existing Pods, so restart the Deployment. A limit that fits the process can still fail if the namespace quota has no room for all replicas.

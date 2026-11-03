---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Taints, Tolerations And Placement Rules

A `nodeSelector` pulls a Pod toward nodes with certain labels. A taint works in the other direction: it pushes Pods away from a node. An administrator uses taints to reserve a node for one kind of workload or to keep Pods off a node that is unhealthy. When a Pod stays `Pending` because of a taint, the repair must respect the reason the taint exists.

## What a taint is

A taint is a key, an optional value and an effect, stored in the `spec.taints` field of a Node. The effect says what the node does to Pods that do not tolerate the taint:

- `NoSchedule`: the scheduler does not place new Pods on the node. Pods that already run there stay.
- `PreferNoSchedule`: the scheduler avoids the node when it has another choice, but may still use it.
- `NoExecute`: the scheduler does not place new Pods there, and the node controller also evicts running Pods that do not tolerate the taint.

A toleration is a field in the Pod spec that matches a taint. With `operator: Equal` the key, value and effect must all match. With `operator: Exists` only the key (and the effect, if given) must match. A toleration only removes the taint as an obstacle. It does not choose the node. A Pod with a toleration can still run on an untainted node, unless a `nodeSelector` or another rule also restricts it.

## Taints that Kubernetes adds by itself

Some taints exist without any administrator action. A kind control plane node, like a kubeadm control plane node, carries `node-role.kubernetes.io/control-plane` with the effect `NoSchedule`, so ordinary workloads do not run there. The node controller, a loop in `kube-controller-manager`, adds taints when a node condition changes. It adds `node.kubernetes.io/not-ready` when the `Ready` condition is `False`, and `node.kubernetes.io/unreachable` when the condition is `Unknown`. Both use the `NoExecute` effect.

Pods that the Deployment controller creates get default tolerations for these two taints with `tolerationSeconds: 300`. This means a Pod on a failed node stays bound for five minutes before eviction. The API server adds the toleration at admission time, so you see it with `kubectl get pod -o yaml` even if you never wrote it.

## Reserve a node and watch the effect

<!-- astrona:playground:renew -->

In the playground, the `scout` Deployment runs two Pods on the worker node. Reserve the worker for survey workloads with a taint:

```sh
kubectl taint nodes -l pool=survey dedicated=survey:NoSchedule
kubectl describe node -l pool=survey
```

The `kubectl taint` command takes the key, value and effect in the form `key=value:effect`. The `describe` output has a `Taints` line that now lists the new taint. The two running `scout` Pods stay, because `NoSchedule` does not evict. Now ask the Deployment controller to create new Pods:

```sh
kubectl -n starfleet rollout restart deployment/scout
kubectl -n starfleet rollout status deployment/scout --timeout=30s
```

The rollout cannot finish. The Deployment controller creates a new ReplicaSet, and its first Pod stays `Pending`. The `rollout status` command ends with a timeout message, because the Deployment has fewer updated replicas than it needs. Describe the pending Pod:

```sh
kubectl -n starfleet get pods -l app=scout
kubectl -n starfleet get events --field-selector reason=FailedScheduling
```

The scheduler event now counts the worker node among the nodes removed because of an untolerated taint, with the key `dedicated`. The message names the taint key, so you can match it with the node. You now know which rule removed the node.

## Repair with a toleration

The taint states that the worker is reserved. The team that owns `scout` is allowed to use it, so the Pod must declare that it tolerates the taint. Removing the taint would open the node to every workload and would undo the reservation. Save this as `scout-toleration.yaml`:

```yaml
spec:
  template:
    spec:
      tolerations:
      - key: dedicated
        operator: Equal
        value: survey
        effect: NoSchedule
```

Apply it as a patch to the Deployment:

```sh
kubectl -n starfleet patch deployment scout --patch-file scout-toleration.yaml
```

Then check the result:

```sh
kubectl -n starfleet rollout status deployment/scout --timeout=120s
kubectl -n starfleet get pods -l app=scout -o wide
```

The patch changes the Pod template, so the Deployment controller starts a new rollout. The new Pods tolerate the taint, the scheduler keeps the worker node in the filter step, and the rollout completes. The taint is still on the node, which you can confirm with `kubectl describe node`.

## Choosing the right fix

Three pieces work together: the node label, the taint on the node and the Pod rules. If a Pod has a `nodeSelector` for `pool: survey` and the node is also tainted, the Pod needs the selector to match and the toleration to exist. Missing either one leaves the Pod `Pending`, so you may need two repairs for one workload. After each repair, read the scheduler event again, because the message lists only the rules that rejected nodes in the last attempt.

A toleration with `operator: Exists` and no key tolerates every taint. It makes a Pod able to run on any tainted node, including a node that is not ready. Use it only for node-level system software.

This part showed that a taint expresses a node rule and a toleration expresses permission. Next comes the case where the node itself is taken out of service on purpose.

## Common pitfalls

> [!WARNING]
> Do not remove a taint just to get a Pod running: the taint is a placement rule, and removing it affects every workload. A toleration does not attract a Pod to a node, it only allows it. A `NoSchedule` taint never evicts running Pods; only `NoExecute` does. After a repair, read the new event again, because a second rule can still reject the node.

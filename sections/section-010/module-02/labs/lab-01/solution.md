---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running, and select its kubeconfig:

```sh
astrona run -c .
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-010-02-01)"
```

## Step 1: Read the scheduling events

The Pods of `scout` are `Pending` and have no node. Describe one of them and read the events:

```sh
kubectl -n starfleet get pods -o wide
kubectl -n starfleet describe pod -l app=scout
```

The `FailedScheduling` event counts the nodes and gives one reason for each. The worker is rejected for more than one reason, but the message shows only the first rule that failed for it. The control plane node is rejected by its own taint, which is correct and stays.

## Step 2: Compare the rules with the node

Read the labels, the taints and the allocatable CPU of the worker, then the Pod template of the Deployment:

```sh
kubectl get nodes --show-labels
kubectl describe node -l pool=survey
kubectl -n starfleet get deployment scout -o yaml
```

The Deployment asks for `pool: surveyor` but the worker has `pool=survey`. The worker has the taint `dedicated=survey:NoSchedule` and the Pod template has no toleration. The Pod template requests 64 CPUs, far more than the worker's allocatable CPU. Each rule rejects the worker on its own, so all three must change.

## Step 3: Patch the Deployment

Save this as `scout-patch.yaml`:

```yaml
spec:
  template:
    spec:
      nodeSelector:
        pool: survey
      tolerations:
      - key: dedicated
        operator: Equal
        value: survey
        effect: NoSchedule
      containers:
      - name: scout
        resources:
          requests:
            cpu: 100m
```

Apply it:

```sh
kubectl -n starfleet patch deployment scout --patch-file scout-patch.yaml
```

The command prints `deployment.apps/scout patched`. A strategic merge patch keeps the other fields of the Deployment and merges the container by its name.

## Step 4: Wait and check

```sh
kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl -n starfleet get pods -o wide
```

Both Pods must be `Running` on the worker node. Check that the node rules are untouched:

```sh
kubectl describe node -l pool=survey
```

The `Taints` line must still list `dedicated=survey:NoSchedule`. Grade it:

```sh
astrona submit -c . --keep
```

All checks must pass. When you finish, remove the lab with `astrona destroy ats-023-lab-010-02-01`.

## Common pitfalls

> [!WARNING]
> Removing the taint or the label, or cordoning the node, hides the original intent and fails the grader. Removing the `nodeSelector` or the CPU request also fails. If a Pod stays `Pending` after your patch, read the event again: it shows the next rule that rejects the node.

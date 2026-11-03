---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Solution

Solve this lab on `terminal`. The capstone is unguided, so this page gives only the order of work and the reasoning. Each check can be run with `astrona submit -c . --keep`.

Start the lab and select its kubeconfig:

```sh
astrona run -c .
export KUBECONFIG="$(astrona kubeconfig ats-023-capstone-010)"
```

## Start with the node

Several workloads fail at once, so read the node first. The worker shows `NotReady`, its `Ready` condition is `Unknown`, and the node controller added the `unreachable` taints. A stale report points at the kubelet. Check it inside the worker node container of this environment and start it:

```sh
podman exec astro-ats-023-capstone-010-worker systemctl is-active kubelet
podman exec astro-ats-023-capstone-010-worker systemctl start kubelet
kubectl wait --for=condition=Ready node/astro-ats-023-capstone-010-worker --timeout=240s
```

The first command prints `inactive`. The wait ends when the node reports `Ready` again. The `dedicated` taint and the `pool` label are intentional, so leave them.

## Read why scout is Pending

The Pods of `scout` have no node. The `FailedScheduling` event names two rules: the `nodeSelector` asks for `pool: survey-east`, and the worker's taint has no toleration. Patch the Pod template so that the selector says `pool: survey` and a toleration for `dedicated=survey` with the effect `NoSchedule` exists.

## Read why probe does not start

The Pods of `probe` have a node, so the kubelet reports the problem. The first state is `ErrImagePull`, caused by the tag `1.37.99`. After the image is set to `docker.io/library/busybox:1.37.0`, the second state appears: `CreateContainerConfigError`, because the reference asks for the key `mode` and the ConfigMap `probe-config` has the key `level`. Correct the reference in the Deployment. Do not add a key to the ConfigMap.

## Prove it

Wait for both rollouts, list the Pods with their nodes and read `LEVEL` inside a `probe` Pod:

```sh
kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet get pods -o wide
kubectl -n starfleet exec deploy/probe -- printenv LEVEL
```

The last command must print `high`. When you finish, remove the lab with `astrona destroy ats-023-capstone-010`.

## Common pitfalls

> [!WARNING]
> Starting the kubelet does not repair the Deployments, and repairing the Deployments does not help while the node is not ready. Removing the taint, cordoning the node, editing the ConfigMap or hard-coding the value passes a Pod check but fails the grader.

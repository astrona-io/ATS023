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
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-010-03-01)"
```

## Step 1: Read the state and the events

```sh
kubectl -n starfleet get pods
kubectl -n starfleet describe pod -l app=probe
kubectl -n starfleet get events --sort-by=.metadata.creationTimestamp
```

The Pods have a node, so the scheduler is not the problem. The container state is `Waiting` with the reason `ErrImagePull` or `ImagePullBackOff`, and the events report a failed pull of `busybox:1.37.99`. That tag does not exist. This is the first fault. The container has not started, so `kubectl logs` shows nothing.

## Step 2: Fix the image

```sh
kubectl -n starfleet set image deployment/probe probe=docker.io/library/busybox:1.37.0
```

The command prints `deployment.apps/probe image updated`. The Deployment starts a new rollout. Look at the new Pods:

```sh
kubectl -n starfleet get pods
kubectl -n starfleet describe pod -l app=probe
```

The image is pulled now, but the new Pods show `CreateContainerConfigError`. The event message says that the ConfigMap `probe-settings` was not found. This is the second fault: the kubelet checks the configuration after the pull.

## Step 3: Fix the ConfigMap reference

List the ConfigMaps. `probe-config` exists and has the key `greeting`, so the Deployment is wrong, not the ConfigMap:

```sh
kubectl -n starfleet get configmap probe-config -o yaml
```

Save this as `probe-patch.yaml`:

```yaml
spec:
  template:
    spec:
      containers:
      - name: probe
        env:
        - name: GREETING
          valueFrom:
            configMapKeyRef:
              name: probe-config
              key: greeting
```

Apply it:

```sh
kubectl -n starfleet patch deployment probe --patch-file probe-patch.yaml
```

The command prints `deployment.apps/probe patched`. The container is merged by its name, and the environment variable is merged by its name.

## Step 4: Wait and check

```sh
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet get pods
kubectl -n starfleet exec deploy/probe -- printenv GREETING
```

Both Pods must be `Running` and `1/1`, and the last command must print `hello`. Grade it:

```sh
astrona submit -c . --keep
```

All checks must pass. When you finish, remove the lab with `astrona destroy ats-023-lab-010-03-01`.

## Common pitfalls

> [!WARNING]
> Creating a ConfigMap called `probe-settings`, editing `probe-config` or replacing the reference with a fixed value passes the Pod check but fails the grader. Deleting a Pod does not help, because the replacement uses the same template. `kubectl rollout undo` cannot help here, because the Deployment has only one revision.

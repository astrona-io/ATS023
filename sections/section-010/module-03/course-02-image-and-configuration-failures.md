---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Image And Configuration Failures

Before the kubelet can start a container, it must pull the image and build the container's environment and volumes from the Pod spec. Two kinds of mistake stop the container at that point: an image reference that the registry cannot serve, and a reference to a ConfigMap or a Secret that does not exist or lacks a key. Both leave the Pod in a waiting state with a clear message, and neither produces a container log.

## Image pull failures

The kubelet asks the container runtime to pull the image named in the container's `image` field. If the pull fails, the container state becomes `Waiting` with the reason `ErrImagePull`. The kubelet then waits and retries with a growing delay, and during the delay the reason changes to `ImagePullBackOff`. Both words mean the same fault, a failed pull. The back-off delay starts at a few seconds and grows up to five minutes.

The event message tells you which cause applies. These are the usual ones:

- The tag does not exist in the registry. The message says that the image was not found, or that the manifest is unknown.
- The repository name has a typo.
- The registry requires credentials, and the Pod has no `imagePullSecrets` entry for it. The message mentions authorization or a denied request.
- The node cannot reach the registry. The message mentions a timeout or a failed name lookup.

The first step is always to compare the image reference in the Deployment with the registry. Setting `imagePullPolicy: Always` does not help a missing tag.

The pull policy decides when the kubelet pulls. With `IfNotPresent` it pulls only when the node has no copy. With `Always` it asks the registry on every start. A tag called `latest` defaults to `Always`, and any other tag defaults to `IfNotPresent`. Changing the image in the Deployment starts a new rollout with new Pods.

A private registry needs credentials. A Secret of type `kubernetes.io/dockerconfigjson` holds them, and the Pod names it in `spec.imagePullSecrets`. The Secret must be in the same namespace as the Pod. If the Secret is missing or wrong, the pull fails with an authorization message, and the image reference itself may be correct. Check the reference first, then the credentials, then the node's network path to the registry, because each step excludes one cause.

<!-- astrona:playground:renew -->

In the playground, the `scout` Deployment in `starfleet` uses a tag that does not exist. Look at its Pods and events:

```sh
kubectl -n starfleet get pods -l app=scout
kubectl -n starfleet describe pod -l app=scout
```

The `STATUS` column alternates between `ErrImagePull` and `ImagePullBackOff`. The `Events` section has `Failed` events from the `kubelet` with the failed pull and a `BackOff` event with the text that the kubelet is backing off pulling the image. Print the image that the Deployment asks for:

```sh
kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}'
```

Fix a wrong tag with `kubectl set image`, which changes the Pod template and starts a rollout:

```sh
kubectl -n starfleet set image deployment/scout scout=docker.io/library/busybox:1.37.0
kubectl -n starfleet rollout status deployment/scout --timeout=120s
```

The argument has the form `container=image`, and the container is named `scout`. The rollout finishes when the new Pods are ready.

## Configuration failures

A container can take its settings from a ConfigMap or a Secret in two ways: as an environment variable through `valueFrom`, or as a file through a volume. For an environment variable, the kubelet reads the object when it builds the container. If the ConfigMap does not exist, or the named key is missing, the kubelet cannot build the container. The state becomes `Waiting` with the reason `CreateContainerConfigError`, and the event message names the missing object or the missing key.

The Pod already has a node and its image is pulled at this point, so the failure comes after the image step. If a Deployment has both a bad image and a missing ConfigMap, you see the image error first. After you fix the image, the config error appears. Treat this as two faults, not as a new problem caused by your fix.

The same mistake in a volume gives a different state. A Pod that mounts a ConfigMap volume for an object that does not exist stays in `ContainerCreating`, with `FailedMount` events from the kubelet, because the kubelet cannot prepare the volume before the container starts.

## Find the missing object or key

The `shuttle` Deployment refers to a ConfigMap that does not exist, and the `bridge` Deployment refers to a ConfigMap that exists but has no key with the requested name:

```sh
kubectl -n starfleet get pods -l app=shuttle
kubectl -n starfleet describe pod -l app=shuttle
kubectl -n starfleet get configmap
```

The `shuttle` Pod shows `CreateContainerConfigError`. The event message says that the ConfigMap was not found, with the name that the Pod asks for. The last command lists the ConfigMaps in the namespace, so you can compare names: a ConfigMap with a similar name may exist. Now look at `bridge`:

```sh
kubectl -n starfleet describe pod -l app=bridge
kubectl -n starfleet get configmap bridge-config -o yaml
```

The event message says that a key could not be found in the ConfigMap `bridge-config`. The ConfigMap's `data` field has a different key. The environment variable reference uses `configMapKeyRef` with the fields `name` and `key`, and both must match exactly. Case matters.

A reference can be marked optional. With `optional: true` on a `configMapKeyRef`, a missing ConfigMap or key does not stop the container: the kubelet starts it and leaves the variable unset. The default is `optional: false`, which is why a missing object stops the container. An optional reference can hide a mistake, because the container starts and then behaves wrongly without its setting. If a container runs but ignores a setting, check whether the reference is optional.

## Choose the right repair

There are two honest repairs. Either correct the reference in the Deployment so that it names the real object and key, or create or fix the missing object so that it matches what the Deployment expects. Choose by asking which side is wrong. If a ConfigMap `shuttle-settings` was never created, create it. If the Deployment has a typo, edit the Deployment. Do not replace a `configMapKeyRef` with a fixed value in the Deployment to make the Pod start: that hides the problem and removes the single place where the setting is managed.

Both repairs trigger a different result. Changing the Deployment creates a new ReplicaSet and new Pods. Creating a missing ConfigMap makes the kubelet's next retry succeed, so the existing Pod starts without a new rollout. A Secret works the same way, with `secretKeyRef`. Pods do not see later changes to a ConfigMap that they use as an environment variable, so changes need a restart with `kubectl rollout restart`.

You now know the two failures that stop a container before it starts. The next part covers containers that start and then fail.

## Common pitfalls

> [!WARNING]
> Do not retry an `ImagePullBackOff` Pod by deleting it: the replacement uses the same bad image. A missing ConfigMap and a missing key give the same status word, so read the event message. Fixing the image can reveal a second fault, because the configuration check comes after the pull. Never replace a `configMapKeyRef` with a literal value to make a Pod start.

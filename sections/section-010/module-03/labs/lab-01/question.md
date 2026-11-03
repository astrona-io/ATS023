---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Repair A Failing Deployment

Solve this question on: `terminal`

Use the kubeconfig of this lab:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-010-03-01)"
```

The `probe` Deployment in `starfleet` has two replicas and none of them runs. The team changed its image and its configuration reference in one update, and the update failed.

1. Find the reason that each `probe` Pod does not run. There is more than one fault, and the second one appears only after the first is fixed.

2. Repair the `probe` Deployment so that both replicas are `Ready`. The container must use the image `docker.io/library/busybox:1.37.0`. The environment variable `GREETING` must come from the key `greeting` of the existing ConfigMap `probe-config`, through a `configMapKeyRef`.

3. Do not edit the ConfigMap, do not replace the reference with a fixed value, and do not delete or scale down the Deployment.

`kubectl` has cluster administrator rights.

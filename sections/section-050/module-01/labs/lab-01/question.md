---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Repair A Service Selector

Restore backend selection while preserving the existing client and listener ports. Use the isolated `starfleet` environment to verify the result.

## Objective

Restore backend selection while preserving the existing client and listener ports.

## Starting state

The Service selector names a release label that no application Pod has. Both application replicas are healthy, but the Service has no eligible backends.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-050-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-lab-050-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Restore the original `probe` Service selector to `app: probe, release: probe`. Keep ClusterIP behavior, client TCP port 80, target port `http` and two healthy replicas. EndpointSlices must contain exactly two ready probe Pod backends and the original client must receive version one.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.

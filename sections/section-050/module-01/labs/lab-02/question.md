---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Repair A Missing Ingress Backend

Trace a failed external route to a nonexistent backend reference and repair it. Use the isolated `starfleet` environment to verify the result.

## Objective

Trace a failed external route to a nonexistent backend reference and repair it.

## Starting state

The lab includes a working Traefik Ingress controller and healthy application. The seeded route points at a nonexistent Service.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-050-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-lab-050-01-02" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Create an Ingress `probe` for class `traefik`, host `probe.local`, Prefix path `/` and backend Service `probe` port 80. The request through the controller with the matching Host header must receive version one. An unmatched host must return 404. Preserve the original application and Service.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.

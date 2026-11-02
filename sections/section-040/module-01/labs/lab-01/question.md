---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Diagnose A Previous Container Exit

Select the previous container log and record the corresponding exit evidence. Use the isolated `starfleet` environment to verify the result.

## Objective

Select the previous container log and record the corresponding exit evidence.

## Starting state

Pod `crash-report` prints a start marker, exits with a nonzero status and restarts. The healthy probe application is separate from that evidence Pod.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-040-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-lab-040-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Leave Pod `crash-report` running its original restart-loop command. Read the previous instance of container `report`. Create ConfigMap `crash-diagnosis` with `container: report`, `exitCode` matching the last terminated instance, and `logMarker: application-started`. The Pod must have restarted at least once and its previous log must contain the marker. Do not delete or repair the evidence Pod.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.

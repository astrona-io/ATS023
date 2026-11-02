---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Diagnose A Previous Container Exit Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-040-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-lab-040-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

Pod `crash-report` prints a start marker, exits with a nonzero status and restarts. The healthy probe application is separate from that evidence Pod.

Inspect the relevant evidence:

```sh
kubectl -n starfleet get pod crash-report -o json
kubectl -n starfleet logs crash-report -c report --previous --timestamps
```

A restart creates a new container instance in the same Pod. Current logs and previous logs describe different instances. The last terminated status supplies the exit code for that previous process. Preserve the evidence Pod so the recorded diagnosis can be checked against the runtime.


Save this as `configmap-crash-diagnosis.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: crash-diagnosis
  namespace: starfleet
data:
  container: report
  exitCode: '12'
  logMarker: application-started
```

Apply the required change:

```sh
kubectl apply -f configmap-crash-diagnosis.yaml
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet logs crash-report -c report --previous
```

Leave Pod `crash-report` running its original restart-loop command. Read the previous instance of container `report`. Create ConfigMap `crash-diagnosis` with `container: report`, `exitCode` matching the last terminated instance, and `logMarker: application-started`. The Pod must have restarted at least once and its previous log must contain the marker. Do not delete or repair the evidence Pod.

After recording the result, remove this independent lab with `astrona destroy ats-023-lab-040-01-01`.

## Common pitfalls

> [!WARNING]
> Current and previous logs belong to different container instances. Preserve the evidence Pod. Record the last terminated exit code rather than assuming a restart means a particular cause.

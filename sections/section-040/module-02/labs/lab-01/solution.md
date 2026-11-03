# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running after a failed check.

Start the lab and select its cluster:

```sh
astrona run -c sections/section-040/module-02/labs/lab-01
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-040-02-01)"
```

## Step 1: Find the failing container of bridge

Pod `bridge` has two containers, so `kubectl logs bridge` alone would ask you to choose. Read each one by name:

```sh
kubectl -n starfleet logs bridge -c api
kubectl -n starfleet logs bridge -c worker
```

The `api` container prints request lines. The `worker` container prints a line that starts with `worker: ERROR code=`. The code after `code=` is the value you need.

Save this as `configmap-error-report.yaml`, with the code you read in place of `<CODE>`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: error-report
  namespace: starfleet
data:
  container: worker
  errorCode: <CODE>
```

Apply it and check the result:

```sh
kubectl apply -f configmap-error-report.yaml
kubectl -n starfleet get configmap error-report -o jsonpath='{.data}'
```

Grade it:

```sh
astrona submit -c sections/section-040/module-02/labs/lab-01 --keep
```

The check `error-report` passes. The check `init-container-fixed` still fails.

## Step 2: Read the init container log and fix the cause

The Pod of `shuttle` shows a status that starts with `Init:`. Find the Pod and read its init container:

```sh
kubectl -n starfleet get pods -l app=shuttle
kubectl -n starfleet logs -l app=shuttle -c fetch-config --tail=5
```

The log shows `fetch-config: mode=draft` and an error that the mode must be `ready`. The init container reads the environment variable `MODE`. Change the variable on the Deployment, not the check:

```sh
kubectl -n starfleet set env deployment/shuttle -c fetch-config MODE=ready
kubectl -n starfleet rollout status deployment/shuttle --timeout=120s
```

The Deployment controller creates a new Pod with the new environment. The init container finishes with exit code 0 and the main container starts. Confirm and grade:

```sh
kubectl -n starfleet get pods -l app=shuttle
astrona submit -c sections/section-040/module-02/labs/lab-01
```

All three checks pass. Remove the lab:

```sh
astrona destroy ats-023-lab-040-02-01
```

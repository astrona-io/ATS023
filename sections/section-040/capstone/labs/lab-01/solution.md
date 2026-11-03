# Solution

This is a reference for review after the attempt. Select the cluster first:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-capstone-040)"
```

Collect the evidence. The exit code is in the container status, the error code is in the log of one container, and the node file is under `/var/log/pods` on the worker:

```sh
kubectl -n starfleet get pod crash-report -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}{"\n"}'
kubectl -n starfleet logs probe --all-containers --prefix
podman exec astro-ats-023-capstone-040-worker sh -c 'ls -d /var/log/pods/starfleet_beacon-logger_*/logger/*'
```

Save this as `configmap-incident-report.yaml`, with your values in place of the placeholders:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: incident-report
  namespace: starfleet
data:
  exitCode: "<EXIT_CODE>"
  workerError: <ERROR_CODE>
  nodeLogFile: <NODE_LOG_FILE>
```

Apply it:

```sh
kubectl apply -f configmap-incident-report.yaml
```

The init container of `shuttle` logs that the mode must be `ready`, and the kubelet journal names the image that `relay` could not pull:

```sh
kubectl -n starfleet logs -l app=shuttle -c fetch-config --tail=3
podman exec astro-ats-023-capstone-040-worker sh -c 'journalctl -u kubelet --no-pager | grep "busybox:1.37.99" | tail -n 2'
```

Fix both Deployments:

```sh
kubectl -n starfleet set env deployment/shuttle -c fetch-config MODE=ready
kubectl -n outpost set image deployment/relay relay=busybox:1.37.0
kubectl -n starfleet rollout status deployment/shuttle --timeout=120s
kubectl -n outpost rollout status deployment/relay --timeout=120s
```

Grade and clean up:

```sh
astrona submit -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-023-capstone-040
```

# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running after a failed check.

Start the lab and select its cluster:

```sh
astrona run -c sections/section-040/module-03/labs/lab-01
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-040-03-01)"
```

## Step 1: Read the container log file on the node

The kubelet stores the log of each container under `/var/log/pods/<namespace>_<pod>_<uid>/<container>/`. The file name is the restart number, so the first run is `0.log`. List the Pod directory on the worker node and read the file:

```sh
podman exec astro-ats-023-lab-040-03-01-worker sh -c 'ls -d /var/log/pods/starfleet_beacon-logger_*/logger/*'
podman exec astro-ats-023-lab-040-03-01-worker sh -c 'cat /var/log/pods/starfleet_beacon-logger_*/logger/0.log'
```

The line has the runtime format: a time stamp, the stream name `stdout`, a letter `F` for a full line, and the message `beacon: audit token=<TOKEN>`. Copy the token and the full path of the file.

## Step 2: Find the pull error in the kubelet journal

The kubelet runs as a systemd service on the node, so its log is in the journal:

```sh
podman exec astro-ats-023-lab-040-03-01-worker sh -c 'journalctl -u kubelet --no-pager | grep -i "pull" | tail -n 5'
```

The lines name the image reference that failed. Write it down exactly as it appears.

Save this as `configmap-node-log-evidence.yaml`, with your values in place of the placeholders:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: node-log-evidence
  namespace: starfleet
data:
  token: <TOKEN>
  logFile: <LOG_FILE_PATH>
  failedImage: <FAILED_IMAGE>
```

Apply it and grade:

```sh
kubectl apply -f configmap-node-log-evidence.yaml
astrona submit -c sections/section-040/module-03/labs/lab-01 --keep
```

The checks `node-log-evidence` and `kubelet-evidence` pass.

## Step 3: Repair the relay image

The image tag `1.37.99` does not exist. Set the tag that the cluster has:

```sh
kubectl -n starfleet set image deployment/relay relay=busybox:1.37.0
kubectl -n starfleet rollout status deployment/relay --timeout=120s
```

The Deployment controller creates a new Pod, the kubelet pulls the image from the node cache and the container starts. Grade the lab and remove it:

```sh
astrona submit -c sections/section-040/module-03/labs/lab-01
astrona destroy ats-023-lab-040-03-01
```

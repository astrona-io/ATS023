# Question

Solve this question on: `terminal`

Use the kubeconfig of this lab:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-040-03-01)"
```

Scenario: Pod `beacon-logger` in `starfleet` ran once on the worker node and printed an audit token. Deployment `relay` in `starfleet` never starts. You must collect the evidence from the node and repair `relay`.

The worker node is the container `astro-ats-023-lab-040-03-01-worker`. Reach it with `podman exec` (or `docker exec`).

1. Find the container log file of `beacon-logger` on the worker node, under `/var/log/pods`. Create the ConfigMap `node-log-evidence` in `starfleet` with the key `token` set to the token printed in that file, and the key `logFile` set to the absolute path of the file on the node.
2. Find in the kubelet journal on the worker node the image reference that the kubelet could not pull for `relay`. Add it to the same ConfigMap as the key `failedImage`.
3. Repair Deployment `relay` so it has an available replica. Use an image that exists. Do not stop the kubelet, delete `beacon-logger` or change the command of `relay`.

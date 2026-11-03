# Question

Solve this question on: `terminal`

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-capstone-040)"
```

Scenario: an incident review needs evidence from three places, and two Deployments do not work. Time limit: 30 minutes.

Create the ConfigMap `incident-report` in `starfleet` with these keys:

- `exitCode`: the exit code of the last terminated instance of the container in Pod `crash-report`.
- `workerError`: the error code that one container of Pod `probe` logged.
- `nodeLogFile`: the absolute path, on the worker node, of the log file that holds the output of Pod `beacon-logger`.

Then repair:

- Deployment `shuttle` in `starfleet` never becomes Available.
- Deployment `relay` in `outpost` never becomes Available.

Keep every evidence Pod, keep the check inside the init container of `shuttle`, keep the command of `relay` and leave the kubelet running.

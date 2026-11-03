# Question

Solve this question on: `terminal`

Use the kubeconfig of this lab:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-040-02-01)"
```

Scenario: the `bridge` Pod in `starfleet` logs a backend error, and the `shuttle` Deployment in `starfleet` never becomes Available.

1. Pod `bridge` has two containers. Exactly one of them logged an `ERROR` line that contains an error code. Create the ConfigMap `error-report` in `starfleet` with the key `container` set to the name of that container and the key `errorCode` set to the code from its log line. Do not delete or change Pod `bridge`.
2. Deployment `shuttle` in `starfleet` has an init container that fails, so its Pod never starts the main container. Find out why from the init container log and fix the cause so that the Deployment has an available replica. Keep the init container and its check in place. Do not delete the Deployment.

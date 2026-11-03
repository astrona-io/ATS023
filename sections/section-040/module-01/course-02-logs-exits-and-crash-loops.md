---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Logs, Exits And Crash Loops

A container exits because it cannot read required configuration. Kubernetes retries it and later displays a crash-loop backoff. The retry delay describes Kubernetes's response, while the first exit and its inputs explain the failure.

## Learning objectives

- Explain standard output and supported log retrieval.
- Select container, instance and observation window.
- Interpret restart and termination evidence.

## Before you start

A Pod is the Kubernetes unit for running one or more containers, and a namespace groups namespaced objects. The playground for this module runs the `crash-report` Pod in `starfleet`. Its container `report` prints one line and exits with status 12 every few seconds, so it always has a restart count and a previous instance to read.

## Responsible components and behavior

The `scout` process exits immediately after reading its configuration. Kubernetes can restart it, but repeated restarts do not fix a missing setting. Application debugging focuses on what the process did, what inputs it received and which dependencies it needed.

A log is a record emitted by software about an event or condition. Logs can include timestamps, request identifiers and error details. A termination record can provide an exit code and reason. Read these together: an error message about a missing setting and an immediate nonzero exit support a different explanation from a memory-limit termination.

A crash loop describes repeated process termination and restart with backoff delays. The displayed backoff reason explains the retry behavior, not the application's original failure. The previous container's logs can be important when the current attempt has barely started. Some logging systems retain those records; local access can depend on runtime retention.

Logs should not be treated as infallible. A final error can be a consequence of an earlier failed dependency, and absent logs do not prove no error occurred. The process may have terminated before logging, written elsewhere or lost buffered output. Check the timeline around configuration and release changes.

Changing many settings at once weakens the diagnosis. A useful hypothesis predicts the evidence and a focused correction. If the address is missing, restoring the expected configuration should allow initialization to pass that point. If it is memory exhaustion, the application usage and enforced boundary need examination.

Protect sensitive data while collecting evidence. Record enough context to reproduce the symptom without exposing tokens, passwords or customer data. Debugging should clarify behavior without creating another incident through diagnostic output.

## Constructing A Failure Timeline

Suppose a new `scout` container starts, reads settings, reports an invalid database address and exits. Its restart count rises. The time of the release, the first log error and the termination record support a startup configuration hypothesis. The backoff delay is a later control response, not the first failing event.

Compare this with memory termination. The final application log might be ordinary because the runtime terminates the process when the resource boundary is exceeded. An absence of a logged application exception does not invalidate that termination evidence. Exit codes and reasons need interpretation alongside the runtime and resource settings.

Logs can also be buffered or written to a destination other than the standard streams collected by the platform. A process killed quickly can lose unwritten messages. Central log retention helps preserve historical attempts, but it can fail independently. Always distinguish missing evidence from evidence that the application succeeded.

## Hypotheses Should Predict A Result

A useful hypothesis states which input or condition caused the failure and what correction would change. “The database address is invalid” predicts a connection-related startup error and progress after a valid value reaches the process. “The application exhausts its memory allowance” predicts termination near the boundary and requires examining usage, leaks and sizing.

Changing the image, credentials, memory and probe at once can make the application run without identifying which change mattered. It can also conceal a new weakness, such as disabled health checks or excessive permissions. Prefer a focused correction supported by evidence and verify the expected transition.

Keep the diagnostic record safe to share. Replace sensitive values with descriptions of their role, retain useful timestamps and include the relevant process or container identity. A strong explanation can demonstrate a configuration fault without copying production credentials into a public issue.

## Read The Restart Evidence

The container status of a Pod keeps three facts apart: the current state, the last terminated state and the restart count. Read all three for `crash-report` and compare them with the two log streams.

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get pod crash-report
kubectl -n starfleet get pod crash-report -o jsonpath='{.status.containerStatuses[0].restartCount}{"\n"}'
kubectl -n starfleet get pod crash-report -o jsonpath='{.status.containerStatuses[0].lastState.terminated}{"\n"}'
```

The first command shows the Pod status column, which is `CrashLoopBackOff` between attempts and `Error` or `Running` for a short time around each attempt. The second prints the number of restarts so far. The third prints the last terminated state as JSON. It contains the fields `exitCode`, `reason`, `startedAt` and `finishedAt`. The exit code is 12 and the reason is `Error`, which means the process ended by itself with a nonzero status.

Next read the events for the Pod and the previous log:

```sh
kubectl -n starfleet describe pod crash-report
kubectl -n starfleet logs crash-report -c report --previous
```

In the `describe` output, the Last State block repeats the termination record and the Events section shows the back-off message from the kubelet. The previous log shows the single marker line `application-started`. Together they give a full timeline: the process started, wrote its marker, exited with 12, and the kubelet delayed the next start.

## How Kubernetes Decides To Restart

The pod field `restartPolicy` controls what the kubelet does after a container exits. `Always` restarts it every time, `OnFailure` restarts it only after a nonzero exit, and `Never` leaves it terminated. The `crash-report` Pod uses `Always`, so even a process that exits with status 0 would be restarted.

After each failed start the kubelet doubles the delay, starting at 10 seconds and capping at 5 minutes, and it resets the delay after the container has run for 10 minutes without failing. This is why a crash loop looks slower over time. The kubelet, not the application, creates this delay, and the `CrashLoopBackOff` status describes the waiting period only.

## Work through the decision

Container status separates the current state from the last terminated state and records a restart count. A currently running attempt can coexist with an earlier failed instance. The log stream you select must belong to the relevant container and attempt if it is to explain that termination.

An exit reason and code provide runtime evidence. Application logs provide the process's perspective, which may be incomplete if output was buffered or the process was killed. A memory termination can leave no final application exception. Compare termination reason, resource settings and the preceding messages rather than treating the last line as a universal cause.

```mermaid
flowchart TB
    I["Process input"] --> E["Process exit"]
    E --> T["Termination record"]
    E --> R["Restart attempt"]
    R --> B["Backoff after repeated failure"]
    L["Application messages"] --> D["Failure timeline"]
    T --> D
```

Backoff follows failed attempts; it is not the original application event that caused the exit.

You can now connect a restart to the relevant process instance and evidence. A focused correction must change the cause, while repeated restarts alone can reproduce the same failure indefinitely.

## Common pitfalls

> [!WARNING]
> A crash-loop delay is not the root cause. The last log line may be a consequence, and restarting without changing the cause can repeat the same failure.

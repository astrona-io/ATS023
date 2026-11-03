---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Selecting The Right Container Log And Time Window

During a rollout, two `probe` replicas can emit messages from different versions. A Deployment-level log shortcut can show only one selected Pod. Useful log diagnosis starts with an explicit Pod, container and time window.

## Learning objectives

- Explain standard output and supported log retrieval.
- Select container, instance and observation window.
- Interpret restart and termination evidence.

## Before you start

A Pod is the Kubernetes unit for running one or more containers, and a namespace groups namespaced objects. The playground for this module runs the `probe` Deployment with two replicas in `starfleet`, the `shuttle` client Pod and the `crash-report` Pod. The commands in this chapter run against that playground.

## Responsible components and behavior

Container logs provide text emitted by a container process through the supported logging path. They can describe application events and errors, but they do not automatically include every file the process writes. Useful diagnosis depends on selecting the correct Pod, container, instance and time window before interpreting the text.

## How The Log Request Reaches The Container

`kubectl logs` does not read files on your machine. It sends a request to the API server, which forwards it to the kubelet on the node that runs the Pod. The kubelet reads the log file that the container runtime wrote for that container and streams the content back. The API server needs permission to reach the kubelet, and you need the `get` verb on the `pods/log` subresource.

This path explains several behaviors. If the node is down or the kubelet is not reachable, `kubectl logs` fails even though the Pod object still exists. If the kubelet has rotated the log file, only the newest file is returned. If the container never started, there is no file, and the command reports that the container is waiting to start.

## Understand What The Logging Path Captures

A process commonly writes standard output and standard error, which the container runtime captures through its logging mechanism. The kubelet, the Kubernetes node agent, can expose supported logs for retrieval. An application that writes only to an internal file might produce little useful output through the ordinary container log interface.

A file logger can be combined with a helper that reads a shared volume and forwards records, but that is an application and platform design choice. Merely adding a second container does not make the original file visible to it. The volume mounts, file permissions and collector settings must connect those responsibilities.

Container logs are not the same as Kubernetes events. An image-pull failure can prevent the process from starting, leaving no application log for the failed attempt. Events and container waiting reasons can describe that preparation failure. A request authorization denial at the API server is also not necessarily recorded in a workload's own log stream.

## Select A Container And Instance

A multi-container Pod contains distinct log streams. Specify or identify whether the relevant stream belongs to the main application, a helper or an init container. A healthy helper's startup message does not explain why the main application exited. Pod-level names alone are insufficient when several processes have different jobs.

A restarted container has a current instance and can have a previous terminated instance whose logs remain available under the node's retention conditions. Asking for the previous instance is useful when the new instance has only emitted startup messages. It does not retrieve unlimited history across every restart or replacement Pod.

A Pod replaced by a Deployment is a different Pod object. Its old log access can disappear as the object, node or stored log data is removed. Central retention can preserve records beyond that lifecycle when configured. Do not assume that increasing replica count or restarting the workload preserves earlier diagnostic evidence.

## Bound And Correlate The Observation

Tail limits and time filters can reduce unrelated output. Timestamps help align application errors with rollout changes, dependency incidents and client symptoms. Clock differences, delayed delivery and buffering still affect interpretation, so a timestamp should be understood as a recorded observation rather than perfect proof of causal order.

A follow operation waits for additional records from the selected stream. Silence can mean that the application has nothing to emit, that it logs elsewhere or that selection is wrong. It does not prove that the process is healthy. Conversely, a warning message does not always mean the request failed; connect it to the relevant request outcome.

Labels can select several Pods, but each record needs enough identity to attribute it to a replica and version. During a rollout, old and new Pods can coexist. Combining their logs without identifying the version can make a corrected error appear to continue in the new release.

## Read The Streams In The Playground

Every request that reaches a `probe` replica is written by the Python web server to its standard error stream. That is a good first example, because it shows that the runtime captures standard error as well as standard output. The `shuttle` Pod acts as the client. First send two requests from `shuttle` to the `probe` Service, then read what one replica recorded.

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec shuttle -- wget -qO- http://probe/health
kubectl -n starfleet exec shuttle -- wget -qO- http://probe/health
kubectl -n starfleet logs deploy/probe --tail=5 --timestamps
```

The Service sends each request to one of the two replicas, so the two requests may have gone to different Pods. The `deploy/probe` form asks kubectl to pick one Pod of the Deployment and read its log. kubectl prints a short notice on standard error that it found more than one Pod and used one of them. You may see only one request line, or both, depending on where the Service sent them. This is why a Deployment shortcut is not enough evidence for a rollout question.

To see every replica with its identity, select the Pods by label and ask kubectl to prefix each line with its source:

```sh
kubectl -n starfleet logs -l app=probe --prefix --tail=5 --timestamps
```

With `-l` the default for `--tail` is 10 lines per Pod when you do not set it, and kubectl opens at most five log requests at the same time unless you raise `--max-log-requests`. The `--prefix` flag adds `[pod/<name>/<container>]` to each line, so the reader can attribute every record to a replica and container. Without it, lines from two replicas blend into one stream that cannot be traced back.

Now compare the current and previous instances of a restarting container. The `crash-report` Pod prints one marker, sleeps two seconds and exits with status 12, and Kubernetes restarts it:

```sh
kubectl -n starfleet logs crash-report -c report --previous --timestamps
kubectl -n starfleet logs crash-report -c report --since=30s --timestamps
kubectl -n starfleet get pod crash-report -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}{"\n"}'
```

The first command reads the instance that ended before the current one. The second limits the current stream to the last 30 seconds. The third prints the exit code of the last terminated instance, which is 12. The log tells you what the process said. The termination record tells you how the runtime saw it end.

## Protect Data And Draw Limited Conclusions

Logs can contain confidential input, tokens or personal information. Authors should describe diagnostic fields without inventing sensitive records or encouraging broad secret collection. Production logging should avoid storing credentials and should control who can read retained records.

Suppose `scout` reports connection refused while trying to contact a backend. The message supports investigating the selected backend address, port and listener. It does not alone prove that a NetworkPolicy caused the failure or that credentials are incorrect. The next observation should distinguish those possibilities using resource relationships and connection behavior.

Use logs to identify the process's perspective, then compare that perspective with Kubernetes status and dependency evidence. A complete explanation states which instance produced the record, what operation failed and what further facts establish the cause. That is stronger than treating one familiar error phrase as a universal diagnosis.

## Work through the decision

The runtime captures supported standard output and standard error streams, and the kubelet exposes the available records. A file written inside a container is not automatically included. A restarted container's previous instance is also different from a Pod that has been deleted and replaced.

First identify the Pod that experienced the symptom, then choose the container within it. `-c` names the container, `--previous` requests retained logs from its preceding terminated instance, and `--since` restricts the time window. A missing previous stream can be normal for a container that never restarted. Local log retention is limited, so these flags do not provide an unlimited historical archive.

```mermaid
flowchart TB
    P["Selected Pod"] --> C["Selected container"]
    C --> I["Current or previous instance"]
    I --> W["Time and record window"]
    W --> L["Attributed log records"]
    L --> D["Comparison with symptom"]
```

A meaningful log record has an identified source, lifecycle instance and observation window.

You can now choose log evidence without merging unrelated replicas or attempts. Status and dependency evidence still provide facts that the application stream may never record.

## Common pitfalls

> [!WARNING]
> Current logs, previous-container logs and old-Pod logs are different evidence. Select the relevant stream and lifecycle instance, and do not confuse missing application records with proof that no startup or infrastructure failure occurred.

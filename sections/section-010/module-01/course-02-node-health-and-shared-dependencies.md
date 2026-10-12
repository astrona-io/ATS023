---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Node Health And Shared Dependencies

Several unrelated Pods fail only on one worker. Their shared node is a stronger initial hypothesis than an identical application bug. Failure distribution helps select the investigation scope.

## Learning objectives

- Distinguish unready, unschedulable and stale reporting.
- Trace kubelet and runtime dependencies.
- Interpret pressure, trust and connectivity evidence.

## Before you start

This chapter is standalone reading material; no running cluster or installed tools are required. A Pod is the Kubernetes unit for running one or more containers, and a namespace groups namespaced objects. Treat the worked configurations as teaching examples rather than recorded observations from a provisioned environment.

## Responsible components and behavior

Several unrelated workloads fail on the same node. That pattern suggests a shared dependency rather than identical application bugs. A node's kubelet reports conditions such as readiness and resource pressure, which help the control plane decide how to treat workloads and scheduling on that node.

A NotReady condition can result from node or kubelet problems, but the condition alone does not identify the root cause. The node's runtime, network connectivity, system resources and communication with the control plane are relevant. Existing containers may behave differently from new startup attempts, so compare the timing and affected operations.

Memory, disk and process pressure can affect execution and lead to eviction. Eviction removes a Pod to protect node operation under configured conditions. A controller may request a replacement, but that replacement needs eligible capacity elsewhere. Repeated eviction and replacement do not guarantee that the underlying pressure disappears.

Disk pressure can involve image filesystems, logs or writable data. A Pod's memory-limit termination is different from node-wide memory pressure: one is tied to a container boundary, while the other concerns node resource availability. Similar symptoms can require different sizing or cleanup decisions.

Storage failures can be shared across many nodes if the external system is unavailable. A volume may fail to attach, mount or serve operations. Read the claim, volume and driver evidence alongside node health. A Ready node does not prove that every external storage dependency works.

Start with the failure distribution: one container, one node, one namespace or many workloads. Then inspect the shared components suggested by that distribution. Broad restarts without a supported explanation can destroy useful evidence and increase disruption.

## Using Failure Distribution To Choose Scope

If one application fails on every node, inspect its common image, configuration and dependencies. If several unrelated applications fail only on one node, inspect that node's runtime, kubelet, network path and resource conditions. If failures cross nodes but share one storage backend, the common backend may be more relevant than either application's code.

This is a hypothesis method, not a certainty. A shared release can affect several applications, and a network outage can affect only selected destinations. The distribution narrows candidates; timestamps and component evidence test the explanation. Avoid turning a pattern into a conclusion before checking the relevant boundary.

Node conditions can identify memory, disk or process pressure. Eviction aims to protect node operation when resource availability becomes unsafe under configured policy. The evicted Pod's controller may request a replacement, but availability still depends on another eligible location. Eviction is therefore a protection action with a workload consequence, not an automatic fix for the resource shortage.

## Storage Failure Stages

A provisioned volume can fail to attach to a node, mount into a Pod or serve application operations after mounting. These stages involve different components and evidence. A bound claim proves a storage association, not that every later operation has completed.

A remote backend outage can affect otherwise Ready nodes. A topology mismatch can prevent access from one location while storage remains healthy elsewhere. A local volume can depend on one node whose failure removes access to the data. The backend's actual availability contract determines what recovery is possible.

Choose the smallest supported scope for correction. Replacing one faulty node can help a node-specific runtime failure; restarting every workload may add disruption without repairing an external storage outage. Preserve evidence and verify from representative consumers after the shared dependency recovers.

## Work through the decision

A runtime outage on one node can stop new container starts while other nodes remain healthy. A storage-service outage can affect consumers across many nodes instead. Group symptoms by operation, location and time before choosing which shared component to inspect.

Container memory-limit termination and node-wide memory pressure are also different boundaries. The first concerns a process's permitted allocation; the second can cause node eviction decisions affecting several workloads. Replacing evicted Pods needs capacity elsewhere and does not repair the original pressure. Broad restarts can remove useful evidence without addressing either cause.

```mermaid
flowchart TB
    N0["Observed failure distribution"]
    N1["Shared dependency hypothesis"]
    N2["Node or external evidence"]
    N3["Focused correction"]
    N4["Original operation verification"]
    N0 --> N1
    N1 --> N2
    N2 --> N3
    N3 --> N4
```

The affected population narrows scope, while specific dependency evidence establishes the cause.

The affected population narrows scope, while specific dependency evidence establishes the cause.

## Common pitfalls

> [!WARNING]
> Node readiness is not a guarantee that every dependency works. Container memory limits, node pressure and storage outages are distinct failure mechanisms.

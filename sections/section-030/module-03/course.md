---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Requests, Limits, OOM Kills And Quotas

A container that restarts every few seconds with exit code 137, a Pod that the API server refuses to create, and a node that looks idle but accepts no more Pods all come from resource settings. This module explains how requests and limits become scheduling decisions, kernel enforcement and namespace policy, and how to read the evidence for each.

## Learning Goals

- Name the Quality of Service class of a Pod from its requests and limits.
- Explain the difference between CPU throttling and a memory out-of-memory kill.
- Diagnose an `OOMKilled` container with exit code 137.
- Read a ResourceQuota and a LimitRange and explain a rejection message.
- Compare a node's allocatable capacity with the requests placed on it.

## Before You Start

You need `kubectl` and the `astrona` command-line tool. The module playground is a private kind cluster with a ResourceQuota, a LimitRange and workloads that are throttled and killed on purpose. The graded task uses a separate cluster.

## Reading Order

The first page defines the three Quality of Service classes and what the kernel does when CPU or memory runs out. The second page follows an out-of-memory kill from the container status to the fix and then reads node capacity. The third page covers ResourceQuota and LimitRange and the errors they produce. A graded task follows it, then the module summary.

<!-- astrona:playground -->

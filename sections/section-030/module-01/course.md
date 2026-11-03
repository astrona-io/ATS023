---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Resource Observations And Capacity Diagnosis

This module explains how to tell apart what a workload declares, what the cluster has measured and what the node enforces. It uses the `probe` Deployment in `starfleet` and the Metrics API to capture live evidence.

## Learning Goals

- Compare specification, status, events and metrics.
- Confirm observation context and permissions.
- Distinguish measured usage from allocation and enforcement.
- Account for complete workload capacity requirements.

## Before You Start

You need a terminal with `kubectl` and the `astrona` command-line tool. The module playground is a private kind cluster with metrics-server already installed, so `kubectl top` works after about a minute. Graded exercises use their own separate environments.

## Reading Order

The first page shows which `kubectl` command reads which source of evidence and why measured usage is a separate signal. A graded task follows it: capture a live Pod measurement.

The second page covers requests, limits, units and the effective demand of a Pod with several containers. The third page is a guided practice that reads the raw Metrics API and stores a sample. The module ends with a summary.

<!-- astrona:playground -->

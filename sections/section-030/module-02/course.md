---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Metrics Server And The Metrics API

When `kubectl top` fails, the application is usually fine and the metrics pipeline is the problem. This module explains how CPU and memory numbers travel from a container to your terminal, which component can break on the way, and how to repair a metrics-server that cannot read from the kubelets.

## Learning Goals

- Trace a usage number from the kubelet through metrics-server and the API server to `kubectl top`.
- Read the `v1beta1.metrics.k8s.io` APIService and its `Available` condition.
- Query the Metrics API directly with `kubectl get --raw`.
- Explain why the HorizontalPodAutoscaler depends on metrics-server.
- Diagnose and repair a metrics-server Deployment that cannot scrape the kubelets.

## Before You Start

You need `kubectl` and the `astrona` command-line tool. The module playground is a private kind cluster that already runs metrics-server and a small `probe` Deployment in `starfleet`. The graded task uses a separate cluster in which metrics-server is broken on purpose.

## Reading Order

The first page follows a usage number along the whole path and names the component at each step. The second page reads the Metrics API and the APIService, shows what the HorizontalPodAutoscaler needs from them and explains the sampling interval. The third page covers the typical errors and the flags that fix them, and it is followed by the graded repair task. The module ends with a summary.

<!-- astrona:playground -->

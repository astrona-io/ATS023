---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Scheduler Failures And Cluster Add-Ons

A stopped scheduler leaves new Pods Pending without any event, and a stopped add-on breaks Service traffic while Pods stay Ready. This module teaches how to recognise each failure, read the evidence and repair the component.

## Learning Goals

- Tell a Pending Pod that cannot be placed from one that no scheduler considered.
- Read the scheduler manifest, its log and the `kube-scheduler` Lease.
- Repair a broken scheduler static Pod and prove placement works.
- Check the `kube-proxy` DaemonSet, its ConfigMap and other `kube-system` add-ons.

## Before You Start

You need basic kubectl skills and a shell with `podman`. The playground is a kind cluster with one control-plane node and one worker node. Graded exercises use independent environments and follow the lessons they practise.

## Reading Order

1. Scheduler Role And Pending Pods
2. Scheduler Static Pod And Leader Election
3. kube-proxy And kube-system Add-Ons
4. Summary

<!-- astrona:playground -->

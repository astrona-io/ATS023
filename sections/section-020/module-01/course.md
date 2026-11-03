---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Control-Plane Responsibility And Failure Scope

This module names the job of each control-plane component and shows how to find the one that stopped. It connects the behaviour you expect from a Deployment to the objects and conditions you can observe.

## Learning Goals

- Identify API, controller, scheduler and datastore responsibilities.
- Trace the first failed workload transition.
- Use local static-Pod evidence when API access fails.
- Distinguish component startup from useful dependent operations.

## Before You Start

You need basic kubectl skills and a shell. The module playground is a kind cluster with one control-plane node and one worker node. Graded exercises use independent environments and follow the lessons they practise.

## Reading Order

1. Control Plane And Worker Responsibilities
2. Locating A Control-Plane Component Failure
3. Guided Practice: Recover A Controller Manager Static Pod
4. Summary

<!-- astrona:playground -->

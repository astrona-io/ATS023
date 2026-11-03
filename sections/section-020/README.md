---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Troubleshoot cluster components

A Deployment is accepted, but its new Pods never receive a node assignment. Request storage succeeded while scheduling did not progress. Naming each component makes that difference explainable.

This section teaches how to find the control-plane component that stopped and how to repair it. The first module covers the responsibilities and the controller manager. The second covers the API server and etcd, which start from files on the control-plane node and take `kubectl` down with them when they fail. The third covers the scheduler, its leader election Lease, the kube-proxy DaemonSet and the other add-ons in `kube-system`. Each module has a playground that runs a kind cluster and a graded lab, and the section ends with a capstone lab and a knowledge check.

Each module begins with its goals and ends with a summary. Every lab and playground in this section starts a kind cluster. The labs are built with static checks only and are marked UNTESTED in their README files.

## Learning Outcomes

- Identify API, controller, scheduler and datastore responsibilities.
- Trace the first failed workload transition.
- Use local static-Pod evidence when API access fails.
- Distinguish component startup from useful dependent operations.
- Edit a static Pod manifest on the control-plane node without leaving the kubelet with two definitions.
- Tell a refused connection, an x509 error, an Unauthorized response and a Forbidden response apart.
- Check etcd health with `etcdctl` and the certificate flags, and compare it with the API server readiness view.
- Recognise a missing scheduler by Pending Pods with no events and a stale `kube-scheduler` Lease.
- Check the kube-proxy DaemonSet, its ConfigMap and the other `kube-system` add-ons.

## Learning Path

### 1. Control-Plane Responsibility And Failure Scope
- Reader: `sections/section-020/module-01/course.md` with two parts, a guided practice page and a summary.
- Playground: `sections/section-020/module-01/playground`
  ```bash
  astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/module-01/playground
  ```
- Lab: Recover A Controller Manager Static Pod, `sections/section-020/module-01/labs/lab-01`
  ```bash
  astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/module-01/labs/lab-01
  astrona submit -c .
  ```

### 2. API Server And etcd Failures
- Reader: `sections/section-020/module-02/course.md` with three parts and a summary.
- Playground: `sections/section-020/module-02/playground`
  ```bash
  astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/module-02/playground
  ```
- Lab: Recover An API Server With A Wrong etcd Address, `sections/section-020/module-02/labs/lab-01`. The fault stops the API server, so the repair uses node access with `podman exec`.
  ```bash
  astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/module-02/labs/lab-01
  astrona submit -c .
  ```

### 3. Scheduler Failures And Cluster Add-Ons
- Reader: `sections/section-020/module-03/course.md` with three parts and a summary.
- Playground: `sections/section-020/module-03/playground`
  ```bash
  astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/module-03/playground
  ```
- Lab: Repair A Broken kube-scheduler Static Pod, `sections/section-020/module-03/labs/lab-01`
  ```bash
  astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/module-03/labs/lab-01
  astrona submit -c .
  ```

### Section Capstone Challenge
- Lab: Troubleshoot Cluster Components Capstone, `sections/section-020/capstone/labs/lab-01`. One cluster has a broken kube-proxy image, a broken controller manager, a broken scheduler and a broken API server etcd address.
  ```bash
  astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/capstone/labs/lab-01
  astrona submit -c .
  ```

### Knowledge Check
- Quiz: `sections/section-020/quiz.yaml` with 14 single-choice questions that cover all three modules.

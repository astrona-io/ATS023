# Troubleshooting (ATS023)

Certified Kubernetes Administrator (CKA): Troubleshooting, worth 30% of the official curriculum. This course belongs to ATP005.

Developed reading lessons explain configuration, component responsibility, worked reasoning and failure limits. Every section has an introduction, and every module ends with a summary. Reusable YAML knowledge checks are indexed separately. Technical content remains draft.

## Course Outline

| Section / module | Module |
| --- | --- |
| 010 / 01 | Node Conditions And Host Diagnosis |
| 010 / 02 | Pending Pods, Taints And Node Maintenance |
| 010 / 03 | Failed Workloads: Events And Pod States |
| 020 / 01 | Control-Plane Responsibility And Failure Scope |
| 020 / 02 | API Server And etcd Failures |
| 020 / 03 | Scheduler Failures And Cluster Add-Ons |
| 030 / 01 | Resource Observations And Capacity Diagnosis |
| 030 / 02 | Metrics Server And The Metrics API |
| 030 / 03 | Requests, Limits, OOM Kills And Quotas |
| 040 / 01 | Output Streams And Runtime Failure Evidence |
| 040 / 02 | Multi-Container Logs And Debug Access |
| 040 / 03 | Node-Level And Component Logs |
| 050 / 01 | Service And External Request Troubleshooting |
| 050 / 02 | Cluster DNS Troubleshooting |
| 050 / 03 | Endpoints, Probes And NetworkPolicy |

Each section ends with a capstone lab and a knowledge-check quiz (`quiz.yaml`, pass score 70). The course ends with the final domain quiz (`sections/final-domain-quiz.yaml`).

## Author Review

The [curriculum map](CURRICULUM.md) records objective coverage. [Sources](SOURCES.md) support author review. The older reusable banks in `assessments/` and `sections/*/questions.yaml` are kept but are no longer registered in `astrona.yaml`. Guided practice and graded labs use private environments.

## Hands-On Coverage

Every module has an ungraded playground (15) and a graded lab; every section has a capstone lab. **Status: all labs and playgrounds are UNTESTED.** They pass static checks only (`astrona validate -c`, `bash -n`, YAML parsing) and were never run against a live cluster.

| Lab | Title |
| --- | --- |
| section-010/module-01/lab-01 | Recover A Stopped Worker Kubelet |
| section-010/module-02/lab-01 | Repair A Pending Deployment |
| section-010/module-03/lab-01 | Repair A Failing Deployment |
| section-010/capstone/lab-01 | Troubleshoot Clusters And Nodes Capstone |
| section-020/module-01/lab-01 | Recover A Controller Manager Static Pod |
| section-020/module-02/lab-01 | Recover An API Server With A Wrong etcd Address |
| section-020/module-03/lab-01 | Repair A Broken kube-scheduler Static Pod |
| section-020/capstone/lab-01 | Troubleshoot Cluster Components Capstone |
| section-030/module-01/lab-01 | Capture Live Pod Metrics |
| section-030/module-02/lab-01 | Repair metrics-server Lab |
| section-030/module-03/lab-01 | Fix OOMKilled And Quota Rejections Lab |
| section-030/capstone/lab-01 | Resource Monitoring Capstone |
| section-040/module-01/lab-01 | Diagnose A Previous Container Exit |
| section-040/module-02/lab-01 | Collect A Container Error And Fix An Init Container |
| section-040/module-03/lab-01 | Find Evidence In Node-Level Logs And Fix A Kubelet-Visible Fault |
| section-040/capstone/lab-01 | Output Streams And Runtime Evidence Capstone |
| section-050/module-01/lab-01 | Repair A Service Selector |
| section-050/module-01/lab-02 | Repair A Missing Ingress Backend |
| section-050/module-02/lab-01 | Repair Cluster DNS |
| section-050/module-03/lab-01 | Repair A Service Port And A Deny Policy |
| section-050/capstone/lab-01 | Troubleshoot Services And Networking Capstone |

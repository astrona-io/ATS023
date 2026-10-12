# Curriculum Coverage

Exam: Certified Kubernetes Administrator (CKA). Domain: Troubleshooting (30%).

The [official objectives](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/) were verified on 2026-10-11. Teaching structure is original; it does not add official exam requirements.

| Section | Official objective | Modules |
| --- | --- | --- |
| 010 | Troubleshoot clusters and nodes | 1 |
| 020 | Troubleshoot cluster components | 1 |
| 030 | Monitor cluster and application resource usage | 1 |
| 040 | Manage and evaluate container output streams | 1 |
| 050 | Troubleshoot services and networking | 1 |

| Section / module | Module | Teaching lessons |
| --- | --- | --- |
| 010 / 01 | Node Conditions And Host Diagnosis | Diagnosing Node Readiness And Host Dependencies; Node Health And Shared Dependencies |
| 020 / 01 | Control-Plane Responsibility And Failure Scope | Control Plane And Worker Responsibilities; Locating A Control-Plane Component Failure |
| 030 / 01 | Resource Observations And Capacity Diagnosis | Choosing Diagnostic Evidence With kubectl; Expressing Resource Needs For Every Container |
| 040 / 01 | Output Streams And Runtime Failure Evidence | Selecting The Right Container Log And Time Window; Logs, Exits And Crash Loops |
| 050 / 01 | Service And External Request Troubleshooting | Tracing A Service Request; Tracing An External Request To The Application |

The module goals and adaptation sources are recorded in AUTHORING.yaml. Every official objective is covered. Each section starts with an introduction, and each module ends with a summary. YAML banks follow the relevant summary and remain separate from the Markdown manifest.

This is a reading-only draft. No new labs, playgrounds, command output or runtime verification are included. ATP005 publication remains draft.

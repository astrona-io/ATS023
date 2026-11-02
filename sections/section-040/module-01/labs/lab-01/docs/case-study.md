---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Starting Environment

Pod `crash-report` prints a start marker, exits with a nonzero status and restarts. The healthy probe application is separate from that evidence Pod.

Leave Pod `crash-report` running its original restart-loop command. Read the previous instance of container `report`. Create ConfigMap `crash-diagnosis` with `container: report`, `exitCode` matching the last terminated instance, and `logMarker: application-started`. The Pod must have restarted at least once and its previous log must contain the marker. Do not delete or repair the evidence Pod.

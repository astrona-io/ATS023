# Primary Authoring Sources

Objectives checked on 2026-10-11. CKA is performance based. These references support author review; learner pages are self-contained. Mechanisms adapted from the KCNA, KCSA and CKAD teaching are recorded per reading in AUTHORING.yaml. The CKA-specific lessons add application definitions, lifecycle decisions and diagnostic reasoning. No runtime or command output is claimed.

- [Official CKA domains and format](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/)
- [Kubernetes concepts](https://kubernetes.io/docs/concepts/)
- [Dockerfile build concepts](https://docs.docker.com/build/concepts/dockerfile/)
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
- [Sidecars](https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/)
- [Volume lifecycle](https://kubernetes.io/docs/concepts/storage/volumes/)
- [Persistent claims](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [API migration](https://kubernetes.io/docs/reference/using-api/deprecation-guide/)
- [Health probes](https://kubernetes.io/docs/concepts/workloads/pods/probes/)
- [Resource allocation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [ServiceAccounts](https://kubernetes.io/docs/concepts/security/service-accounts/)
- [Security contexts](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
- [NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Application diagnosis](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/)
- [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
- [Helm package use](https://helm.sh/docs/intro/using_helm/)

Check version-specific fields and tool options against the intended platform before adding executable examples. YAML checks are original learning material, not an examination simulator.

## Administrator-Specific References

- [kubeadm host prerequisites](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
- [kubeadm cluster creation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
- [Supported kubeadm upgrade process](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
- [Highly available kubeadm topology](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)
- [Etcd operation and recovery](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)
- [HPA behavior](https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/)
- [CoreDNS diagnosis](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)
- [Gateway API responsibilities](https://gateway-api.sigs.k8s.io/docs/concepts/api-overview/)
- [Cross-namespace reference grants](https://gateway-api.sigs.k8s.io/reference/api-types/referencegrant/)

---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Summary

The API server and etcd start from manifest files on the control-plane node. The kubelet scans the static Pod directory, starts a container for each file and shows a read-only mirror Pod in the API. The file is the source of truth, so deleting the mirror Pod changes nothing, and a stray backup file in that directory can change what runs. When the API is down, the container runtime on the node still lists the containers and their logs.

The API server flags decide which layer a request fails in. The secure port gives a refused connection when nothing listens. The serving certificate and the certificate authority give an x509 error when trust does not match. The client certificate authority and tokens give an Unauthorized response, and missing RBAC rules give Forbidden. The etcd address and certificate flags give a server that runs but cannot store anything, which the health endpoints report as a failing etcd check.

etcd listens for clients on port 2379 and for peers on port 2380, and it requires client certificates. A health check with `etcdctl` needs the endpoint, the CA, a client certificate and its key. Comparing the direct etcd result with the API server's own etcd check separates an etcd failure from a broken connection between them.

A safe repair copies the manifest, edits the copy and moves it into place in one step, then waits for one scan interval and for readiness. Success is shown by a ready API server and a successful write, not by the edit alone.

<!-- astrona:playground:destroy -->

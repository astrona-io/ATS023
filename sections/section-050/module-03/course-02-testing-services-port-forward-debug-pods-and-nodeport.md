---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Testing Services: Port-Forward, Debug Pods And NodePort

To find the broken layer you need tests that cut the path at different places. One test goes straight to a pod and skips the Service. One test starts from a temporary client inside the cluster. One test enters through a port on the node. This part shows what each test proves, what it skips, and how `kube-proxy` makes a Service address and a NodePort work.

## Learning objectives

- Use `kubectl port-forward` to separate an application fault from a Service fault.
- Run a temporary debug pod in the namespace of the failing client.
- Create a NodePort Service and explain what `kube-proxy` does with it.

## Port-forward goes around the Service

`kubectl port-forward` opens a tunnel from a port on your machine to a port in a pod. The kubelet on the pod's node opens the connection, and the API server carries it. The request never uses the Service cluster IP, the `kube-proxy` rules or the endpoint selection. A forward to `svc/probe` is a shortcut: `kubectl` picks one pod behind the Service and forwards to its port.

That makes it a good test for one question: does the application answer when everything between is removed? If a forward to the pod works and the Service request fails, the fault is in the Service, the slice, `kube-proxy` or a policy. If the forward fails too, the fault is in the pod: the process, its listening address or its port.

Run the forward in one terminal and keep it open. It forwards local port 8081 to port 8080 of one `probe` pod:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet port-forward deployment/probe 8081:8080
```

In a second terminal, with the same kubeconfig, send a request to the local port:

```sh
curl -s http://127.0.0.1:8081/
```

The reply is a line that starts with `version=v1` and names the pod that answered. Stop the forward with Ctrl+C. This forward works whatever the Services say, because it names the pod port 8080 directly. That is why it proves the pod is healthy while the wrong target port of `probe-alt` stays hidden in the Service. Because the tunnel is made by the kubelet and not by another pod, a port-forward does not show whether a client pod is allowed by a NetworkPolicy.

## A debug pod tests the client path

The caller of a Service is a pod, so test from a pod. A temporary pod in the failing namespace has the same resolver search path and, if labels match, the same policies. Run one request and remove the pod when it exits:

```sh
kubectl -n outpost run debug-client --rm -i --restart=Never --image=docker.io/library/busybox:1.37.0 -- wget -q -T 3 -O- http://probe.starfleet/
```

The `--rm` flag deletes the pod after it finishes, `-i` attaches to its output, and `--restart=Never` makes it a plain pod and not a Deployment. The request comes from `outpost`, so it tests exactly the path that the `drifter` pod uses. A debug pod gets only the labels you give it. If a NetworkPolicy allows pods with `app=shuttle`, the debug pod passes only when it carries that label: add `--labels=app=shuttle` to test as that client. Use the image that the cluster already has, because a cluster without internet access cannot pull a new one.

## NodePort and kube-proxy

A Service of type NodePort opens the same port number on every node. A connection to the node address and that port reaches the Service. The cluster allocates the number from a range that defaults to 30000 to 32767. `kube-proxy` is the component that makes this work. It runs on every node, in a kubeadm cluster as a DaemonSet in `kube-system` with the label `k8s-app=kube-proxy`. It watches Services and EndpointSlices and programs the node's packet rules: one set rewrites the cluster IP and port to a chosen pod endpoint, and another set does the same for the node port. The rules can use iptables, IPVS or nftables, depending on the mode.

Save this as `service-probe-node.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe-node
  namespace: starfleet
spec:
  type: NodePort
  selector:
    app: probe
  ports:
    - name: http
      port: 80
      targetPort: http
```

Apply it:

```sh
kubectl apply -f service-probe-node.yaml
```

Then check the result, and read the `kube-proxy` pod that runs on the node:

```sh
kubectl -n starfleet get service probe-node
kubectl -n kube-system get pods -l k8s-app=kube-proxy -o wide
```

The Service lists the port pair as `80:` followed by the allocated node port. Now call it from the `shuttle` pod through the node address. Read the values into variables first:

```sh
NODE_IP="$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')"
NODE_PORT="$(kubectl -n starfleet get service probe-node -o jsonpath='{.spec.ports[0].nodePort}')"
kubectl -n starfleet exec deploy/shuttle -- wget -q -T 3 -O- "http://$NODE_IP:$NODE_PORT/"
```

The request returns a line that starts with `version=v1`. If it fails while the cluster IP works, read the logs of the `kube-proxy` pod. If the node port works from inside but not from outside, a firewall or the container runtime's port mapping is the next suspect: in a kind cluster the nodes are containers, and their node ports are not published to your machine.

## Order of tests

Use the cheapest test that cuts the path in half. Start with the slice, because it costs one command. Use port-forward to test the pod without the Service. Use a debug pod to test the client path, and a node port to test `kube-proxy` and the node. Each test that passes removes a stage from the list.

You can now cut a failing path at three points and name the component that each cut skips. The last layer that filters connections is the NetworkPolicy.

## Common pitfalls

> [!WARNING]
> A port-forward works when the Service, the endpoints or a NetworkPolicy block real clients, so a working forward does not prove the Service is healthy. A debug pod with different labels or a different namespace is not the failing client. Do not publish a Service as NodePort to fix a fault, because it opens a port on every node.

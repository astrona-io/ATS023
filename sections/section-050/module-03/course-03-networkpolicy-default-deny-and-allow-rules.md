---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# NetworkPolicy: Default Deny And Allow Rules

By default every pod in a cluster can connect to every other pod. A NetworkPolicy changes that for the pods it selects. It also adds a new kind of fault: the Service, the endpoints and the application are all correct, and the connection still times out because a policy drops the packets. This part explains how a policy selects pods, how default deny and allow rules combine, and how to test a policy so you know it is enforced.

## Learning objectives

- Explain how a NetworkPolicy selects pods and isolates them.
- Write a default-deny policy and an allow rule for one client.
- State the condition under which a cluster enforces NetworkPolicy, and test it.

## How a policy works

A NetworkPolicy is a namespaced API object with three main parts. `podSelector` chooses the pods the policy applies to, in its own namespace. `policyTypes` lists the directions the policy controls: `Ingress` for connections into the pods, `Egress` for connections out of them. The `ingress` and `egress` lists hold allow rules. A rule names the peers (`from` or `to`) and, optionally, the ports.

The model has two rules to remember. A pod that no policy selects for a direction accepts all traffic in that direction. As soon as one policy selects a pod for `Ingress`, that pod is isolated for ingress: only connections that some policy allows get through. Policies only allow. There is no deny rule. Several policies on one pod add together, and the pod accepts the union of what they allow, so the order of the policies does not matter.

A policy that selects every pod with `podSelector: {}` and lists `Ingress` without any `ingress` rule is a default deny for ingress. It isolates every pod in its namespace and allows nothing.

## The condition: the network plugin must enforce policies

The API server stores a NetworkPolicy, but it does not enforce it. The network plugin (the Container Network Interface, CNI, plugin) on the nodes does. The Kubernetes documentation states that a policy created without a plugin that implements it has no effect. So the first question for a policy fault is not what the policy says, but whether this cluster enforces policies at all. Test it before you trust it: apply a default deny and check that a request that worked now fails. If it still works, the plugin ignores policies, and every later test of a policy proves nothing.

## Apply a default deny

<!-- astrona:playground:renew -->

Save this as `networkpolicy-default-deny.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: starfleet
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

Apply it:

```sh
kubectl apply -f networkpolicy-default-deny.yaml
```

Then check the result from the `shuttle` pod. Run it on its own, because a blocked request returns a nonzero status:

```sh
kubectl -n starfleet exec deploy/shuttle -- wget -q -T 3 -O- http://probe/
```

If the plugin enforces policies, the request waits for 3 seconds and fails, because the packets are dropped and nobody sends a refusal. If it still prints `version=v1`, the plugin does not enforce policies in this cluster. The rest of this part assumes that it does.

A timeout here is different from the fast refusal of the port mismatch. A drop gives silence, and a closed port gives a rejection. That one difference often tells a policy fault from a port fault.

## Allow one client on one port

Now add a rule that lets the `shuttle` pods reach the `probe` pods. Two details decide whether it works. The selector in `from` is a pod selector in the policy's own namespace. The port is the pod port, because the Service has already translated the Service port to the `targetPort` before the policy sees the packet: the rule needs 8080, not 80.

Save this as `networkpolicy-allow-shuttle-to-probe.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-shuttle-to-probe
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: shuttle
      ports:
        - protocol: TCP
          port: 8080
```

Apply it:

```sh
kubectl apply -f networkpolicy-allow-shuttle-to-probe.yaml
```

Then check both clients. The first request passes. The second comes from another namespace and fails when policies are enforced:

```sh
kubectl -n starfleet exec deploy/shuttle -- wget -q -T 3 -O- http://probe/
kubectl -n outpost exec deploy/drifter -- wget -q -T 3 -O- http://probe.starfleet/
```

The `from` entry has no `namespaceSelector`, so it matches only pods in `starfleet`. To allow a client in another namespace, a rule needs a `namespaceSelector`. The namespace label `kubernetes.io/metadata.name` holds the namespace name, so `kubernetes.io/metadata.name: outpost` selects that one namespace.

## Over-broad rules and mistakes to look for

A fix that ends the timeout by opening everything is not a fix. A rule with no `from`, a `from` with an empty `namespaceSelector: {}` or an empty `podSelector: {}`, and an `ipBlock` of `0.0.0.0/0` all allow wide sources. Deleting the default deny has the same effect. Choose the narrowest rule that serves the client.

Other common mistakes are a selector that matches no pod because of a label typo, a rule that sits in the wrong namespace, a port that names the Service port instead of the pod port, and a default deny for `Egress` that also blocks DNS. A pod that is isolated for egress cannot reach CoreDNS unless a rule allows UDP and TCP port 53 to the `kube-dns` pods in `kube-system`.

You can now read a policy, explain why a connection is dropped, and write the smallest rule that restores a client. The method for any policy fault is the same: prove that the plugin enforces policies, find which policy selects the pod, compare the rule with the client's labels and the pod port, and test from the real client.

## Common pitfalls

> [!WARNING]
> A NetworkPolicy has no effect on a cluster whose network plugin does not enforce it, so test enforcement first. Policies only allow, so you cannot cancel one with another. Use the pod port in a rule, not the Service port, and never remove the default deny or allow every source just to end a timeout.

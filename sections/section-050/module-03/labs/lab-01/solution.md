# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/module-03/labs/lab-01
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-050-03-01)"
```

## Step 1: Compare the Service port with the container port

The Service sends traffic to its `targetPort`. The containers listen on the port that the application binds, which is 8080 here. Read both:

```sh
kubectl -n starfleet get service probe -o jsonpath='{.spec.ports[0].targetPort}{"\n"}'
kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].ports}{"\n"}'
kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe
```

The Service forwards to 9090, the container declares 8080, and the EndpointSlice lists the endpoints on port 9090. Endpoints exist because both pods are ready, but nothing listens on 9090.

## Step 2: Point the Service at the named port

Save this as `service-probe.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe
  namespace: starfleet
spec:
  selector:
    app: probe
  ports:
    - name: http
      port: 80
      targetPort: http
```

Apply it:

```sh
kubectl apply -f service-probe.yaml
```

Then check the result:

```sh
kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe -o jsonpath='{.items[*].ports[*].port}{"\n"}'
```

The port is now 8080. Grade it: the check `service-endpoints` passes.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/module-03/labs/lab-01 --keep
```

## Step 3: Find the second fault

Test again from the client pod:

```sh
kubectl -n starfleet exec deploy/shuttle -- wget -q -T 3 -O- http://probe/
kubectl -n starfleet get networkpolicies
```

If your network plugin enforces NetworkPolicy, the request times out, because `default-deny-ingress` selects every pod (`podSelector: {}`) and has no allow rule. If the request works, your plugin does not enforce policies. The grader checks the policy objects in that case.

## Step 4: Add the allow rule

A NetworkPolicy only adds allow rules. Port numbers in a policy are pod ports, so the rule uses 8080, not the Service port 80. Save this as `networkpolicy-allow-shuttle-to-probe.yaml`:

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

Then check the result:

```sh
kubectl -n starfleet exec deploy/shuttle -- wget -q -T 3 -O- http://probe/
kubectl -n outpost exec deploy/drifter -- wget -q -T 3 -O- http://probe.starfleet/
```

The first command prints a line that starts with `version=v1`. The second command from `drifter` times out when the network plugin enforces policies. Run the second one on its own, because it returns a nonzero status.

## Step 5: Grade and clean up

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/module-03/labs/lab-01
astrona destroy ats-023-lab-050-03-01
```

All five checks pass. Deleting `default-deny-ingress` makes the request work but fails the `allow-policy` and `isolation-kept` checks.

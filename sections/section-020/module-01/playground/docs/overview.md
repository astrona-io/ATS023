---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Guided Practice: Recover A Controller Manager Static Pod

Use a host shell with the private kubeconfig for this module playground. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-playground-020-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-playground-020-01" || exit 1
node_name="astro-ats-023-playground-020-01-control-plane"
worker_name="astro-ats-023-playground-020-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Inspect And Explain

The controller-manager static Pod contains an invalid duration flag and cannot run. Existing application Pods still serve version one. The API server stays reachable.

Inspect the current objects before changing them:

```sh
kubectl -n starfleet get pods -o wide
kubectl get nodes -o wide
```

The worker and API server remain healthy, but the controller manager has an invalid leader-election duration. Inspect its Pod status and previous logs. Restore --leader-elect-lease-duration=15s, keep the API available, then update probe to VERSION=v2 and verify two updated, ready and available replicas. Record controller-recovery with component kube-controller-manager and result restored. A working older replica alone does not prove the controller resumed reconciliation.

Save this as `recover-controller.py`:

```python
import json,subprocess,tempfile
from pathlib import Path
CONTEXT="kind-astro-ats-023-playground-020-01"
NODE="astro-ats-023-playground-020-01-control-plane"
def run(*args):
    result=subprocess.run(args,check=True,text=True,capture_output=True,timeout=30)
    return result.stdout.strip()
assert run('kubectl','config','current-context')==CONTEXT, 'Select the private environment'
assert run('podman','inspect',NODE,'--format','{{index .Config.Labels "io.x-k8s.kind.cluster"}}')=='astro-ats-023-playground-020-01', 'Refusing an unrelated node container'
def node(*args):return run('podman','exec',NODE,*args)
def put(path,content):
    with tempfile.TemporaryDirectory(prefix='training-node-') as temporary:
        source=Path(temporary)/'content';source.write_text(content)
        run('podman','cp',str(source),NODE+':'+path)
def api_manifest():
    with tempfile.TemporaryDirectory(prefix='training-api-') as temporary:
        source=Path(temporary)/'pod.yaml';source.write_text(node('cat','/etc/kubernetes/manifests/kube-controller-manager.yaml'))
        return json.loads(run('kubectl','create','--dry-run=client','--validate=false','-f',str(source),'-o','json'))
def set_api_flag(flag,value):
    manifest=api_manifest(); container=manifest['spec']['containers'][0]
    container['command']=[arg for arg in container['command'] if not arg.startswith('--'+flag+'=')]+['--'+flag+'='+value]
    put('/etc/kubernetes/lab-api-pod.json',json.dumps(manifest))
    node('mv','/etc/kubernetes/lab-api-pod.json','/etc/kubernetes/manifests/kube-controller-manager.yaml')

set_api_flag('leader-elect-lease-duration','15s')
```

Save this as `deployment-probe.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: probe
      release: probe
  template:
    metadata:
      labels:
        app: probe
        release: probe
    spec:
      containers:
      - name: probe
        image: docker.io/library/python:3.13-alpine
        command:
        - python
        - /app/server.py
        env:
        - name: VERSION
          value: v2
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /ready
            port: http
          periodSeconds: 2
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
          limits:
            memory: 128Mi
        volumeMounts:
        - name: app
          mountPath: /app
          readOnly: true
      volumes:
      - name: app
        configMap:
          name: probe-code
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: controller-recovery
  namespace: starfleet
data:
  component: kube-controller-manager
  result: restored
```

Apply the correction:

```sh
python3 recover-controller.py
kubectl -n kube-system wait --for=condition=Ready pod/kube-controller-manager-astro-ats-023-playground-020-01-control-plane --timeout=240s
kubectl apply -f deployment-probe.yaml
kubectl -n starfleet rollout status deployment/probe --timeout=180s
```

## Verify The Result

Observe the actual result. A denied request returns a nonzero status when the denial works, so run it separately from a shell sequence that stops on error. Status convergence and a successful request establish different parts of the result.

```sh
kubectl get --raw=/readyz
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

Repair an invalid controller-manager flag and verify that Deployment reconciliation resumes. The commands above deliberately target one environment. Keep its remaining components available so an unrelated failure cannot stand in for the required denial or correction. No example command output is presented as evidence of a completed run. A matching field alone does not establish that a process used it or that a controller reconciled it.


## Common pitfalls

> [!WARNING]
> A ready API server does not prove the controller manager is running. Inspect its own configuration and previous logs, then verify a fresh template update reconciles. Keep backup files outside the kubelet static-manifest directory.

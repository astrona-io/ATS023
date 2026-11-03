worker=get('node','astro-ats-023-playground-010-01-worker',namespace='')
assert not worker['spec'].get('unschedulable',False), 'Leave the recovered worker schedulable'
assert any(c['type']=='Ready' and c['status']=='True' for c in worker['status']['conditions']), 'Restore worker readiness'
assert command(['podman','exec','astro-ats-023-playground-010-01-worker','systemctl','is-active','kubelet']).stdout.strip()=='active', 'Restore the actual kubelet service'

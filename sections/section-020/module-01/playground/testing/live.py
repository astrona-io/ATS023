pod=get('pod','kube-controller-manager-astro-ats-023-playground-020-01-control-plane',namespace='kube-system')
assert '--leader-elect-lease-duration=15s' in pod['spec']['containers'][0]['command'], 'Repair the current controller-manager configuration'
assert any(condition['type']=='Ready' and condition['status']=='True' for condition in pod['status'].get('conditions',[])), 'Restore the controller process'

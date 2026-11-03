evidence=get('pod','crash-report')
assert evidence['spec']['containers'][0]['command']==['sh','-c','printf "application-started\\n"; sleep 2; exit 12'], 'Preserve the evidence process'
status=next(status for status in evidence['status']['containerStatuses'] if status['name']=='report')
assert status['restartCount']>=1, 'Inspect a real previous container instance'
assert str(status['lastState']['terminated']['exitCode'])==get('configmap','crash-diagnosis')['data']['exitCode'], 'Record the actual previous exit code'

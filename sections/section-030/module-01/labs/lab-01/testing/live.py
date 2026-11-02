from datetime import datetime,timezone
sample=json.loads(get('configmap','metric-report')['data']['sampleJson'])
assert sample['kind']=='PodMetricsList', 'Record the Pod metrics collection'
live_metrics=json.loads(kubectl('get','--raw','/apis/metrics.k8s.io/v1beta1/namespaces/starfleet/pods'))
assert live_metrics.get('items'), 'Metrics API must return live measurements'
pods=json.loads(kubectl('-n','starfleet','get','pods','-l','app=probe','-o','json'))['items']
required={pod['metadata']['name'] for pod in pods if any(status.get('ready') for status in pod.get('status',{}).get('containerStatuses',[]))}
recorded={item['metadata']['name']:item for item in sample['items']}
assert len(required)==2 and required<=recorded.keys(), 'Record both ready application Pods'
for name in required:
    item=recorded[name]
    assert item['metadata']['namespace']=='starfleet', 'Record the correct namespace'
    age=(datetime.now(timezone.utc)-datetime.fromisoformat(item['timestamp'].replace('Z','+00:00'))).total_seconds()
    assert 0<=age<=600 and item['window'], 'Record a recent measurement window'
    assert len(item['containers'])==1 and item['containers'][0]['name']=='probe', 'Record the application container measurement'
    assert all(container.get('usage',{}).get('cpu') and container.get('usage',{}).get('memory') for container in item['containers']), 'Record CPU and memory usage'

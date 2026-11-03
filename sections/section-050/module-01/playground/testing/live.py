slices=json.loads(kubectl('-n','starfleet','get','endpointslices','-l','kubernetes.io/service-name=probe','-o','json'))
ready=[endpoint for item in slices['items'] for endpoint in item.get('endpoints',[]) if endpoint.get('conditions',{}).get('ready') is True]
assert len(ready)==2 and all(endpoint['targetRef']['name'].startswith('probe-') for endpoint in ready), 'Restore both original ready backends'

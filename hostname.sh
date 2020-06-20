#!/bin/sh
for PODNAME in `kubectl get pods -l app=sample-app -o jsonpath='{.items[*].metadata.name}'`; do
  kubectl exec -it ${PODNAME} -- sh -c "hostname > /usr/share/nginx/html/index.html";
done


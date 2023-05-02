# stuff

## podinfo for passthru test

tweak dubbd
```
# disable kyverno policies
kyvernopolicies:
  enabled: false

# set hostname for passthru in istio values
istio:
  enabled: true
  ingressGateways:
    passthrough-ingressgateway:
      type: "LoadBalancer"
      kubernetesResourceSpec:
        resources:
          requests:
            cpu: "100m"
            memory: "512Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
  gateways:
    passthrough:
      ingressGateway: passthrough-ingressgateway
      hosts:
        - podinfo.{{ .Values.domain }}
      tls:
        mode: "PASSTHROUGH"
```

install podinfo
```
# create ns
kubectl create -f podinfo-ns.yaml

# create secret
mkcert podinfo.bigbang.dev
kubectl -n podinfo create secret tls podinfo-tls-secret --key ./podinfo.bigbang.dev-key.pem  --cert ./podinfo.bigbang.dev.pem
kubectl patch sa default -n podinfo -p '"imagePullSecrets": [{"name": "podinfo-tls-secret" }]'

# helm install
helm upgrade -i podinfo -n podinfo --set=tls.enabled=true,tls.secretName=podinfo-tls-secret oci://ghcr.io/stefanprodan/charts/podinfo
```

test podinfo
```
# find lb ip from within multipass vm
kubectl get svc -A | grep -i loadbalancer

# socat from within multipass vm
socat TCP-LISTEN:8443,fork,reuseaddr TCP:172.20.1.234:443

# edit hosts file to add entry for podinfo on hosts
<MULTIPASS 10.x IP> podinfo.bigbang.dev

# curl on host
curl -kLvvv https://podinfo.bigbang.dev:8443
```

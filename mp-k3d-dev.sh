#!/bin/bash

IMAGE_CACHE=${HOME}/.k3d-container-image-cache
mkdir -p ${IMAGE_CACHE}

PRIVATE_IP=false
#METAL_LB=false
METAL_LB=true

#K3S_IMAGE=rancher/k3s:v1.23.17-k3s1
K3S_IMAGE=rancher/k3s:v1.26.4-k3s1

# Get the public IP address of our instance
PublicIP=$(hostname -I|awk '{print $1}')

# Get the private IP address of our instance
PrivateIP=$(hostname -I|awk '{print $NF}')

echo
echo "Instance ${InstId} is ready!"
echo "Instance private IP is ${PrivateIP}"
echo "Instance public IP is ${PublicIP}"
echo


echo "k3d version"
k3d version
echo

echo "creating k3d cluster"

# Shared k3d settings across all options
# 1 server, 3 agents
#k3d_command="k3d cluster create --servers 1  --agents 3"
k3d_command="k3d cluster create "
# Volumes to support Twistlock defenders
#k3d_command+=" -v /etc:/etc:*\;agent:* -v /dev/log:/dev/log:*\;agent:* -v /run/systemd/private:/run/systemd/private:*\;agent:*"
k3d_command+=" -v /etc/machine-id:/etc/machine-id    -v /${IMAGE_CACHE}:/var/lib/rancher/k3s/agent/containerd/io.containerd.content.v1.content"
# Disable traefik and metrics-server
#k3d_command+=" --k3s-arg "--disable=traefik@server:0"   --k3s-arg "--disable=metrics-server@server:0""
# Disable traefik
k3d_command+=" --k3s-arg "--disable=traefik@server:0""
# Port mappings to support Istio ingress + API access
k3d_command+=" --port 80:80@loadbalancer --port 443:443@loadbalancer --api-port 6443"
#k3d_command+=" --port 8080:80@loadbalancer --port 8443:443@loadbalancer"
#k3d_command+=" --port 31380:31380@loadbalancer --port 31390:31390@loadbalancer"
#k3d_command+=" --port 31480:31480@loadbalancer --port 31490:31490@loadbalancer"
#k3d_command+=" --port 31580:31580@loadbalancer --port 31590:31590@loadbalancer"
#k3d_command+=" --api-port 6443"
# Specify k3s version for cluster
k3d_command+=" --image ${K3S_IMAGE}"

# Add MetalLB specific k3d config
if [[ "$METAL_LB" == true ]]; then
  # create docker network for k3d cluster
  echo "creating docker network for k3d cluster"
  docker network create k3d-network --driver=bridge --subnet=172.20.0.0/16 --gateway 172.20.0.1
  k3d_command+=" --k3s-arg "--disable=servicelb@server:0" --network k3d-network"
fi

# Add Public/Private IP specific k3d config
if [[ "$PRIVATE_IP" == true ]]; then
  echo "using private ip for k3d"
  k3d_command+=" --k3s-arg "--tls-san=${PrivateIP}@server:0""
else
  echo "using public ip for k3d"
  k3d_command+=" --k3s-arg "--tls-san=${PublicIP}@server:0""
fi

# Create k3d cluster
${k3d_command}
kubectl config use-context k3d-k3s-default
kubectl cluster-info

# Handle MetalLB cluster resource creation
if [[ "$METAL_LB" == true ]]; then
  echo "installing MetalLB"
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml
  #run this command on remote
  cat << EOF > metallb-config.yaml
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: core-net-172.20.1.233-172.20.1.243
  namespace: metallb-system
spec:
  addresses:
  - 172.20.1.233-172.20.1.243
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: metallb-pool
  namespace: metallb-system
spec:
  ipAddressPools:
  - core-net-172.20.1.233-172.20.1.243
EOF

  kubectl wait deployment controller -n metallb-system --for condition=Available=True --timeout=90s
  kubectl rollout status daemonset speaker -n metallb-system --timeout 240s
  kubectl create -f metallb-config.yaml
fi

#if [[ "$METAL_LB" == true ]]; then
#  # run this command on remote
#  # fix /etc/hosts for new cluster
#  sudo sed -i '/bigbang.dev/d' /etc/hosts
#  sudo bash -c "echo '## begin bigbang.dev section' >> /etc/hosts"
#  sudo bash -c "echo 172.20.1.240  keycloak.bigbang.dev vault.bigbang.dev >> /etc/hosts"
#  sudo bash -c "echo 172.20.1.241 anchore-api.bigbang.dev anchore.bigbang.dev argocd.bigbang.dev gitlab.bigbang.dev registry.bigbang.dev tracing.bigbang.dev kiali.bigbang.dev kibana.bigbang.dev chat.bigbang.dev minio.bigbang.dev minio-api.bigbang.dev alertmanager.bigbang.dev grafana.bigbang.dev prometheus.bigbang.dev nexus.bigbang.dev sonarqube.bigbang.dev tempo.bigbang.dev twistlock.bigbang.dev >> /etc/hosts"
#  sudo bash -c "echo '## end bigbang.dev section' >> /etc/hosts"
#  # run kubectl to add keycloak and vault's hostname/IP to the configmap for coredns, restart coredns
#  kubectl get configmap -n kube-system coredns -o yaml | sed '/^    172.20.0.1 host.k3d.internal$/a\ \ \ \ 172.20.1.240 keycloak.bigbang.dev vault.bigbang.dev' | kubectl apply -f -
#  kubectl delete pod -n kube-system -l k8s-app=kube-dns
#fi

echo
echo "================================================================================"
echo "====================== DEPLOYMENT FINISHED ====================================="
echo "================================================================================"
echo

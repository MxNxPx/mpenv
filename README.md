# mpenv
multipass dev environment

> **Warning**
>
> - System minimum compute requirements are at LEAST 48 GB RAM and 12 virtual CPU threads

## setup

```sh
# pull down this repo
git clone --recursive https://github.com/MxNxPx/mpenv && cd mpenv

# launch vm
date; time bash multipass-setup.sh

# shell into vm and swith to root user
multipass exec mpenv -- sudo bash

# run final-setup script (asdf stuff)
date; cd ../ && time bash final-setup.sh
```

## pull down zarf components
```sh
export ZARF_VER="v0.29.2"
wget -P ~/.zarf-cache/ "https://github.com/defenseunicorns/zarf/releases/download/${ZARF_VER}/zarf-init-amd64-${ZARF_VER}.tar.zst"
wget -O /usr/local/bin/zarf "https://github.com/defenseunicorns/zarf/releases/download/${ZARF_VER}/zarf_${ZARF_VER}_Linux_amd64" && chmod 755 /usr/local/bin/zarf
```

## zarf package bb work
```sh
# setup creds (look for "robot-ironbank+zarf-defenseunicorns-dev" in DU #zarf channel)
set +o history
export REGISTRY1_USERNAME="YOUR-USERNAME-HERE"
export REGISTRY1_PASSWORD="YOUR-PASSWORD-HERE"
echo $REGISTRY1_PASSWORD | zarf tools registry login registry1.dso.mil --username $REGISTRY1_USERNAME --password-stdin
set -o history

# create zarf package
date; time zarf package create --architecture amd64 --confirm

# k3d cluster setup
date; time bash ../../mp-k3d-dev.sh
date; time zarf init --confirm --components git-server

# k3s cluster setup
date; time zarf init --confirm --components=k3s,git-server

# deploy bb
date; time zarf package deploy --confirm zarf-package-*.tar.zst

# optional: monitor the deploy
watch 'kubectl get hr -A; echo; kubectl get po -A'
```

## teardown

```sh
# (optional) delete cluster - from within the vm
k3d cluster delete
# wipe the vm - from the host machine
date; multipass delete mpenv && multipass purge
```

# mpenv
multipass dev environment

## setup

```sh
date; time bash multipass-setup.sh
multipass shell mpenv
sudo su -
date; time bash final-setup.sh
```

## zarf package bb work
```sh
# clone into workdir
git clone --branch zarf-bb --recursive https://github.com/MxNxPx/mpenv workdir

# build zarf
cd zarf
date; time make init-package
export PATH=$(pwd)/build:$PATH
ln -s $(pwd)/build/zarf-init-amd64-*.tar.zst ~/.zarf-cache/

# setup creds
set +o history
export REGISTRY1_USERNAME="YOUR-USERNAME-HERE"
export REGISTRY1_PASSWORD="YOUR-PASSWORD-HERE"
echo $REGISTRY1_PASSWORD | zarf tools registry login registry1.dso.mil --username $REGISTRY1_USERNAME --password-stdin
set -o history

# package bb
cd ../zarf-package-big-bang/defense-unicorns-distro
cp -pfv zarf.yaml{,.orig} && cp -pfv ~/workdir/zarf-bb-work/* .
time zarf package create --confirm

# cluster setup
date; time k3d cluster create
date; time zarf init --confirm --components git-server

# deploy bb
date; time zarf package deploy --confirm zarf-package-big-bang-*.tar.zst
```

## teardown

```sh
multipass delete mpenv && multipass purge
```

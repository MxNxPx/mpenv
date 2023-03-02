# mpenv
multipass dev environment

## setup

```sh
bash multipass-setup.sh
multipass shell mpenv
sudo su -
bash final-setup.sh
```

## zarf package bb work
```sh
# clear workingdir
mkdir ~/workdir
cp -Rpfv ~/mpenv/* ~/workdir
cd ~/workdir

# build zarf
cd zarf
time make init-package
export PATH=$(pwd)/build:$PATH
ln -s $(pwd)/build/zarf-init-amd64-*.tar.zst ~/.zarf-cache/

# setup creds
set +o history
export REGISTRY1_USERNAME=""
export REGISTRY1_PASSWORD=""
echo $REGISTRY1_PASSWORD | zarf tools registry login registry1.dso.mil --username $REGISTRY1_USERNAME --password-stdin
set -o history

# package bb
cd ../zarf-package-big-bang/
#BBVER="1.53.0"; sed -i.bak "s|^\(.*BIGBANG_VERSION :=\)\(.*[0-9].*\)$|\1 $BBVER|g" Makefile
time make build

# cluster setup
time k3d cluster create
time zarf init --confirm --components git-server

# deploy bb
time zarf package deploy --confirm $(ls -1 build/zarf-package-big-bang-*.tar.zst)
```

## teardown

```sh
multipass delete mpenv && multipass purge
```

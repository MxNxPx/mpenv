# other-stuff

## update local hosts with mpenv IP

```sh
# looks for host entry in local hosts file and replaces IP with mpenv ip
export MPENV_IP=$(multipass info mpenv --format json | jq -r '.info.mpenv.ipv4[0]') && sudo sed -i.bak -r "s/^ *[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+( +mpenv.vm)/$MPENV_IP\1/" /etc/hosts
```

## zarf package bb work

```sh
# clone into workdir
git clone --branch zarf-bb --recursive https://github.com/MxNxPx/mpenv workdir && cd workdir

# build zarf
cd zarf
date; time make init-package
export PATH=$(pwd)/build:$PATH
ln -s $(pwd)/build/zarf-init-amd64-*.tar.zst ~/.zarf-cache/
```

## teardown

```sh
date; multipass delete mpenv && multipass purge
```

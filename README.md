# mpenv
multipass dev environment

## setup

```sh
# pull down this repo
git clone --recursive https://github.com/MxNxPx/mpenv && cd mpenv

# launch vm
date; time bash multipass-setup.sh

# shell into vm and swith to root user
multipass shell mpenv
sudo su -

# run final-setup script (asdf stuff)
date; time bash final-setup.sh
```

## pull down zarf components
```sh
export ZARF_VER="v0.25.0"
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

# backup original files (for easier reverts)
cd mpenv/zarf-package-big-bang/defense-unicorns-distro
cp -pfv zarf.yaml ../../zarf.yaml.orig && cp -pfv zarf-config.yaml ../../zarf-config.yaml.orig

# patch the zarf.yaml
sed -i '/^components:/ r ../../zarf-bb-work/zarf.yaml-other-images.patch' zarf.yaml && sed -i '/^\(.*\)- [^\n]*/,$!b;//{x;//p;g};//!H;$!d;x;s//&\n\1- custom-values.yaml/' zarf.yaml
cp -fv ../../zarf-bb-work/custom-values.yaml .

# create zarf package
date; time zarf package create --architecture amd64 --confirm

# cluster setup
date; time bash ../../mp-k3d-dev.sh
date; time zarf init --confirm --components git-server

# deploy bb
date; time zarf package deploy --confirm zarf-package-big-bang-*.tar.zst

# optional: monitor the deploy
watch 'kubectl get hr -A; echo; kubectl get po -A'
```

## teardown

```sh
date; multipass delete mpenv && multipass purge
```

# other-stuff

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

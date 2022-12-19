# mpenv
multipass dev environment

## setup

```sh
bash multipass-setup.sh
multipass shell mpenv
sudo su -
bash final-setup.sh
cd workdir
```

## teardown

```sh
multipass delete mpenv && multipass purge
```

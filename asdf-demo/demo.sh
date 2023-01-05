#!/bin/bash

. /usr/local/share/demo-magic.sh
clear;echo;echo;
PROMPT_TIMEOUT=0
MSG="LET'S GET THIS DEMO STARTED..."
COW="./tux-big.cow"
pe "echo \$MSG | cowsay -f \$COW"

## show asdf under the hood
echo;echo
p "[.] asdf install and plugin setup"
pei "grep -i asdf ~/.bashrc"

## install plugins from global .tool-versions
pei "cd ~/; echo \$pwd"
echo;echo
pe "cat ./.tool-versions"
echo;echo
pei "asdfdsa"

## change back to git repo path and install versions
echo;echo
pei "cd -; echo \$pwd"
echo;echo
pe "cat ./.tool-versions"
echo;echo
pei "asdfdsa"

## look at some versions
echo;echo
p "[.] asdf dynamic versions"
pei "asdf list"

## show diff versions based on path
echo;echo
pei "cd -; echo \$pwd"
pe "grep kubectl .tool-versions"
pe "kubectl version --short --client"
echo;echo
pei "cd -; echo \$pwd"
pei "grep kubectl .tool-versions"
pe "kubectl version --short --client"

## other helpful commands
echo;echo
p "[.] asdf helpful commands"
pe "asdf current"
echo;echo
pe "asdf which kubectl"
echo;echo
pe "asdf latest kubectl"


## other stuff to demo
#export VER="v0.23.1"; export URL="https://github.com/defenseunicorns/zarf/releases/download/${VER}/zarf_${VER}_Linux_amd64"; curl --create-dirs -sLo /usr/local/bin/zarf "$URL"
#export VER="v0.23.1"; export URL="https://github.com/defenseunicorns/zarf/releases/download/${VER}/zarf-init-amd64-${VER}.tar.zst"; curl --create-dirs -sLo /root/.zarf-cache/zarf-init-amd64-${VER}.tar.zst "$URL"
#cd /root/.zarf-cache/
#zarf init --components=k3s,git-server --confirm
#cd /tmp
#git clone --branch feature/add-delivery-option-zarf https://github.com/MxNxPx/podtato-head.git
#cd podtato-head/delivery/zarf/
#zarf package create . --confirm
#zarf package deploy zarf-package-podtato-head-amd64.tar.zst --confirm


PROMPT_TIMEOUT=0
COW="./clippy.cow"
echo;echo
MSG="COMPLETE. CAN I DEMO ANYTHING ELSE?"
pe "echo \$MSG | cowsay -f \$COW"
echo;echo


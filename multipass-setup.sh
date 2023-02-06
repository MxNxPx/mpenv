#!/bin/bash
NAME=mpenv
IMAGE=20.04
CPU=8
MEM=24G
DISK=99G
ADD_ARGS=""
#ADD_ARGS="-vvvv"

## unset any proxy env vars
unset PROXY HTTP_PROXY HTTPS_PROXY http_proxy https_proxy

## launch multipass
multipass launch $IMAGE --name $NAME --cpus $CPU --memory $MEM --disk $DISK --cloud-init ./cloud-init.yaml $ADD_ARGS
sleep 10

## mount current dir into the multipass instance
multipass mount . $NAME:/root/$NAME

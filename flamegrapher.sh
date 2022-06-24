#!/bin/bash

docker build -t flamegrapher .
kubectl create -f trace-namespace.yaml
mkdir -p /var/run/flamegraph
kubectl create -f flamegrapher-pod.yaml


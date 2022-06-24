#!/bin/bash

echo Installing packages
apt install -y iperf3 git perl bcc linux-tools-common linux-tools-generic

echo Installing FlameGraph package
mkdir ~/install
cd ~/install
git clone https://github.com/brendangregg/FlameGraph
export PATH=$PATH:~/install/FlameGraph:.

echo Done

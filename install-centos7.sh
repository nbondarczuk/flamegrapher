#!/bin/bash

echo Installing packages
yum install -y iperf3 git perl bcc bcc-devel bcc-tools devtoolset-10-perftools perf sudo elfutils-libelf-devel libunwind-devel audit-libs-devel slang-devel

echo Installing FlameGraph package
mkdir ~/install
cd ~/install
git clone https://github.com/brendangregg/FlameGraph
export PATH=$PATH:~/install/FlameGraph:.

echo Done

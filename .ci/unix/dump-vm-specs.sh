#!/usr/bin/env bash

# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2019 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

if [ "$(uname)" == "Darwin" ]; then
    sw_vers
    top -l 1 -s 0 | grep PhysMem
    sysctl hw
    df -h
    cat /etc/hosts
    sudo scutil --get HostName || true
    sudo scutil --get LocalHostName || true
elif [ "$(uname)" == "Linux" ]; then
    if [ "$(which lsb_release)" == "" ]; then
        sudo apt install -y lsb-release
    fi
    lsb_release -a
    free -m
    lscpu
    df -h --total
else
    echo "Unknown system: $(uname)"
    exit 1
fi
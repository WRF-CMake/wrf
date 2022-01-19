#!/usr/bin/env bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
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
        if [ -f /etc/redhat-release ]; then
            sudo yum install -y redhat-lsb-core
        else
            sudo apt install -y lsb-release
        fi
    fi
    if [ "$(which free)" == "" ]; then
        if [ "$(lsb_release -i -s)" == "CentOS" ]; then
            sudo yum install -y procps
        else
            sudo apt-get install -y procps
        fi
    fi
    lsb_release -a
    free -m
    lscpu
    df -h --total
else
    echo "Unknown system: $(uname)"
    exit 1
fi
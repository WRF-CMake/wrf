#!/usr/bin/env bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2019 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

if [ "$(uname)" == "Linux" ]; then
    sudo fallocate -l 12g /extra_swap
    sudo chmod 0600 /extra_swap
    sudo mkswap /extra_swap
    sudo swapon /extra_swap
    cat /proc/swaps
fi
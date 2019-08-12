#!/usr/bin/env bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2019 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

SCRIPTDIR=$(dirname "$0")
cd $SCRIPTDIR/../..

if [ "$(uname)" == "Darwin" ]; then

    pip3 install delocate
    delocate-listdeps --all --depending build/install/main
    delocate-path build/install/main
    delocate-listdeps --all --depending build/install/main

else
    echo "Unknown OS: $(uname)"
    exit 1
fi
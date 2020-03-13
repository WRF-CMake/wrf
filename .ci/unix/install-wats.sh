#!/usr/bin/env bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

SCRIPTDIR=$(dirname "$0")
cd $SCRIPTDIR/../..

curl -L --retry 3 https://github.com/$WATS_REPO/archive/$WATS_BRANCH.tar.gz | tar xz
mv wats-$WATS_BRANCH wats
conda env update -n base -f wats/environment.yml

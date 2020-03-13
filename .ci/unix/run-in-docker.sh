#!/usr/bin/env bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

SCRIPTDIR=$(dirname "$0")
ROOTDIR=$SCRIPTDIR/../..
cd $ROOTDIR

container=wrf-ci

# Create container if it doesn't exist
if [ ! "$(docker ps -q -f name=$container)" ]; then
    docker run -n $container -d -v $ROOTDIR:$ROOTDIR -w $ROOTDIR -e DOCKER=1 $IMAGE
    
    # Install sudo
    if [[ $OS_NAME == CentOS ]]; then
      docker exec -t $container sh -c "yum install -y sudo"
    else
      docker exec -t $container sh -c "apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" -y install sudo"
    fi
fi

# Run command in container
docker exec -t $container "$@"

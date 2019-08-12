#!/bin/bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2019 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

HTTP_RETRIES=3

pushd /tmp
# TODO use release once branch has been merged.
git clone https://github.com/WRF-CMake/netcdf-c.git -b mingw-support
cd netcdf-c
mkdir build && cd build
CC=gcc cmake -DCMAKE_GENERATOR="MSYS Makefiles" \
    -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DBUILD_TESTING=OFF -DENABLE_TESTS=OFF -DENABLE_DAP=FALSE \
    -DNC_FIND_SHARED_LIBS=OFF -DBUILD_UTILITIES=OFF -DENABLE_EXAMPLES=OFF \
    -DCMAKE_INSTALL_PREFIX=$MINGW_PREFIX ..
make -j 4
make install
rm -rf $MINGW_PREFIX/lib/cmake/netCDF # breaks for some reason otherwise in netcdf-fortran
rm -rf * # avoid cmake cache using this directly in netcdf-fortran

cd /tmp
curl --retry ${HTTP_RETRIES} https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.4.4.tar.gz | tar xz
cd netcdf-fortran-4.4.4
sed -i 's/ADD_SUBDIRECTORY(examples)/#ADD_SUBDIRECTORY(examples)/' CMakeLists.txt # patch CMakeLists.txt and comment out example building
mkdir build && cd build
CC=gcc FC=gfortran cmake -DCMAKE_GENERATOR="MSYS Makefiles" \
    -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DENABLE_TESTS=OFF \
    -DCMAKE_INSTALL_PREFIX=$MINGW_PREFIX ..
make -j 4
make install
popd
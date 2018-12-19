#!/bin/bash

# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

if [[ $TRAVIS_OS_NAME == 'linux' ]]; then

    sudo apt-get update

    # Travis CI is currently on Ubuntu 14.04 which has netCDF 4.1.
    # All versions of netCDF <= 4.1 contain all components (incl. Fortran libraries),
    # whereas netCDF > 4.1 is split up into separate libraries.
    # As soon as Travis CI switches to a new Ubuntu version, the below has to be adapted.
    # Note: netcdf-bin is only necessary as it provides nc-config which is part of libnetcdf-dev
    # in later Ubuntu versions.
    sudo apt-get install gfortran libnetcdf-dev netcdf-bin libpng-dev libjasper-dev

    if [ $SYSTEM == "make" ]; then
        sudo apt-get install csh m4 libhdf5-serial-dev
    fi

    if [[ $MODE == dm* ]]; then
        sudo apt-get install libmpich-dev
    fi

    # Ubuntu 14.04 does not offer nf-config, however WRF-Make's configure script relies on it
    # to detect whether NetCDF v4 support is available. Since nc-config has the same CLI, just symlink. 
    sudo ln -sf /usr/bin/nc-config /usr/bin/nf-config

    whereis nf-config
    nf-config --has-nc4

elif [[ $TRAVIS_OS_NAME == 'osx' ]]; then

    # If c++ is already present on the system, homebrew fails to install gcc.
    # Use the `-f` flag in case c++ is not present to avoid errors.
    rm -f /usr/local/include/c++

    brew update
    brew install gcc netcdf jasper

    if [[ $MODE == dm* ]]; then
        brew install mpich
    fi

    # Homebrew installs the CMake version of netcdf which doesn't have nf-config support:
    # "nf-config not yet implemented for cmake builds".
    # This means WRF-Make won't enable NetCDF v4 support. For some reason, symlinking nc-config
    # to nf-config (as done for Ubuntu, see above) doesn't work here:
    # "/usr/local/bin/nf-config: fork: Resource temporarily unavailable"
    which nf-config
    # nf-config --has-nc4

else
    echo "The environment is not recognised"
fi

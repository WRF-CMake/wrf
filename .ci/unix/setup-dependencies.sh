#!/bin/bash

# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

SCRIPTDIR=$(dirname "$0")

source $SCRIPTDIR/retry.sh

HTTP_RETRIES=3

if [ "$(uname)" == "Linux" ]; then

    echo "APT::Acquire::Retries \"${HTTP_RETRIES}\";" | sudo tee /etc/apt/apt.conf.d/80-retries

    sudo apt-get update
    sudo apt-get install -y software-properties-common curl cmake

    if [ "$(lsb_release -c -s)" == "trusty" ]; then
        # We don't use latest compiler versions for 14.04 as we would otherwise
        # also have to build both netcdf-c and netcdf-fortran, whereas on
        # newer Ubuntu these two are separate packages and we just have to
        # build netcdf-fortran. 14.04 is kept for Travis CI only. 

        # Ubuntu 14.04 provides netCDF 4.1. All versions of netCDF <= 4.1 contain
        # all components (incl. Fortran libraries), whereas netCDF > 4.1 is split
        # up into separate libraries.
        # Note: netcdf-bin is only necessary as it provides nc-config which is pulled
        # in via libnetcdf-dev in later Ubuntu versions.
        sudo apt-get install gfortran libnetcdf-dev netcdf-bin

        # Ubuntu 14.04 does not offer nf-config, however WRF-Make's configure script relies on it
        # to detect whether NetCDF v4 support is available.
        # Since nc-config has the same CLI, just symlink. 
        sudo ln -sf /usr/bin/nc-config /usr/bin/nf-config
    else
        # macOS (via Homebrew) and Windows (via MSYS2) always provide the latest
        # compiler versions. On Ubuntu, we need to opt-in explicitly. 
        sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test

        sudo apt-get update
        sudo apt-get install -y $CC $FC libpng-dev
        sudo apt-get install -y libnetcdf-dev

        if [ "$(lsb_release -c -s)" == "xenial" ]; then
            sudo apt-get install -y libjasper-dev 
        else
            # From bionic onwards, libjasper is not available via apt-get.
            cd /tmp
            curl --retry ${HTTP_RETRIES} https://www.ece.uvic.ca/~frodo/jasper/software/jasper-2.0.14.tar.gz | tar xz
            cd jasper-2.0.14/build/
            cmake -DCMAKE_INSTALL_PREFIX=/usr ..
            sudo make install
        fi

        # Need to build netcdf-fortran manually as the Fortran compiler versions have to match.
        cd /tmp
        curl --retry ${HTTP_RETRIES} https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.4.4.tar.gz | tar xz
        cd netcdf-fortran-4.4.4
        sed -i 's/ADD_SUBDIRECTORY(examples)/#ADD_SUBDIRECTORY(examples)/' CMakeLists.txt
        mkdir build && cd build
        cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr ..
        make -j 4
        sudo make install
    fi

    if [ $BUILD_SYSTEM == 'Make' ]; then
        sudo apt-get install -y csh m4 libhdf5-serial-dev
    fi

    if [[ $MODE == dm* ]]; then
        if [ "$(lsb_release -c -s)" == "trusty" ]; then
            sudo apt-get install -y libmpich-dev
        else
            # Need to build mpich manually as the Fortran compiler versions have to match.
            MPICH_VERSION=3.2.1
            cd /tmp
            curl --retry ${HTTP_RETRIES} http://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz | tar xz
            cd mpich-${MPICH_VERSION}
            ./configure --prefix=/usr
            make -j 4
            sudo make install
        fi
    fi

    nc-config --all
    nf-config --all || true

elif [ "$(uname)" == "Darwin" ]; then

    # If c++ is already present on the system, homebrew fails to install gcc.
    # Use the `-f` flag in case c++ is not present to avoid errors.
    rm -f /usr/local/include/c++

    # Don't fall-back to source build if bottle download fails for some reason (e.g. network issues).
    # Source builds generally take too long in CI. This setting let's brew fail immediately.
    export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=1

    # Retry downloads if there was a failure.
    # Used only for bottles, but not during 'brew update' which uses git internally.
    export HOMEBREW_CURL_RETRIES=${HTTP_RETRIES}

    # Disable automatic cleanup, just takes time.
    export HOMEBREW_NO_INSTALL_CLEANUP=1

    # 'brew update' uses git and does not have a retry option, so we wrap it.
    retry brew update -v

    # Since "brew install" can't silently ignore already installed packages
    # we're using this instead.
    # See https://github.com/Homebrew/brew/issues/2491#issuecomment-294264745.
    brew bundle --verbose --no-upgrade --file=$SCRIPTDIR/Brewfile

    nc-config --all

    # Homebrew installs the CMake version of netcdf which doesn't have nf-config support:
    # "nf-config not yet implemented for cmake builds".
    # This means WRF-Make won't enable NetCDF v4 support. For some reason, symlinking nc-config
    # to nf-config (as done for Ubuntu, see above) doesn't work here:
    # "/usr/local/bin/nf-config: fork: Resource temporarily unavailable"
    which nf-config
    #nf-config --has-nc4

else
    echo "The environment is not recognised"
    exit 1
fi

if [[ $MODE == dm* ]]; then
    mpif90 -v
fi

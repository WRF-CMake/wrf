#!/usr/bin/env bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

SCRIPTDIR=$(dirname "$0")

source $SCRIPTDIR/retry.sh

HTTP_RETRIES=3

if [ "$(uname)" == "Linux" ]; then

    NINJA_VERSION=1.10.2
    CMAKE_VERSION=3.17.5
    JASPER_VERSION=2.0.33
    SZIP_VERSION=2.1.1
    HDF5_VERSION=1.10.8
    NETCDF_C_VERSION=4.8.1
    NETCDF_FORTRAN_VERSION=4.5.4
    MPICH_VERSION=3.4

    if [ "$(lsb_release -i -s)" == "Ubuntu" ]; then
        echo "APT::Acquire::Retries \"${HTTP_RETRIES}\";" | sudo tee /etc/apt/apt.conf.d/80-retries

        # software-properties-common provides add-apt-repository used below.
        sudo apt-get update
        sudo apt-get install -y software-properties-common

        # macOS (via Homebrew) and Windows (via MSYS2) always provide the latest
        # compiler versions. On Ubuntu, we need to opt-in explicitly. 
        sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test

        sudo apt-get install -y curl unzip make m4 $CC $FC libpng-dev libjpeg-dev

        if [ $BUILD_SYSTEM == 'Make' ]; then
            sudo apt-get install -y cpp csh libhdf5-serial-dev
            sudo ln -sf $(which cpp) /lib/cpp
        fi
        
    elif [ "$(lsb_release -i -s)" == "CentOS" ]; then
        # Note: The manylinux Docker image already contains the latest compilers.

        sudo yum install -y \
            xz unzip zlib-devel libpng-devel libjpeg-devel

        if [ $BUILD_SYSTEM == 'Make' ]; then
            sudo yum install -y tcsh m4
            sudo ln -sf $(which cpp) /lib/cpp
            # Used in WPS.
            sudo ln -sf $(which cpp) /usr/bin/cpp
        fi
    else
        echo "The environment is not recognised"
        exit 1
    fi

    cd /tmp

    # CMake
    curl -L --retry ${HTTP_RETRIES} https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh -o cmake.sh
    sudo bash cmake.sh --prefix=/usr --exclude-subdir --skip-license

    # Ninja
    curl -L --retry ${HTTP_RETRIES} https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip -o ninja-linux.zip
    sudo unzip ninja-linux.zip -d /usr/bin

    # libjasper
    curl -L --retry ${HTTP_RETRIES} https://github.com/mdadams/jasper/archive/version-${JASPER_VERSION}.tar.gz | tar xz
    pushd jasper-version-${JASPER_VERSION}/build/
    cmake -GNinja -DCMAKE_INSTALL_PREFIX=/usr ..
    sudo ninja install
    popd

    # libszip
    curl -L --retry ${HTTP_RETRIES} https://support.hdfgroup.org/ftp/lib-external/szip/${SZIP_VERSION}/src/szip-${SZIP_VERSION}.tar.gz | tar xz
    pushd szip-${SZIP_VERSION}
    ./configure --prefix=/usr
    sudo make install -j$(nproc)
    popd

    # libhdf5
    HDF5_VERSION_BASE=${HDF5_VERSION%.*}
    curl -L --retry ${HTTP_RETRIES} https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${HDF5_VERSION_BASE}/hdf5-${HDF5_VERSION}/src/CMake-hdf5-${HDF5_VERSION}.tar.gz | tar xz
    pushd CMake-hdf5-${HDF5_VERSION}/hdf5-${HDF5_VERSION}
    mkdir build
    cd build
    cmake -GNinja \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_TESTING=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_SKIP_RPATH=ON \
        -DHDF5_BUILD_HL_LIB=ON \
        -DHDF5_BUILD_CPP_LIB=OFF \
        -DHDF5_BUILD_FORTRAN=ON \
        -DHDF5_BUILD_TOOLS=OFF \
        -DHDF5_BUILD_EXAMPLES=OFF \
        -DHDF5_ENABLE_DEPRECATED_SYMBOLS=ON \
        -DHDF5_ENABLE_SZIP_SUPPORT=ON \
        -DHDF5_ENABLE_Z_LIB_SUPPORT=ON \
        -LA ..
    sudo ninja install
    # for WRF-Make
    sudo ln -s /usr/lib/libhdf5_hl_fortran.so /usr/lib/libhdf5hl_fortran.so &&
    popd

    # libnetcdf
    curl -L --retry ${HTTP_RETRIES} https://github.com/Unidata/netcdf-c/archive/v${NETCDF_C_VERSION}.tar.gz | tar xz
    pushd netcdf-c-${NETCDF_C_VERSION}
    ./configure --prefix=/usr \
        --disable-doxygen \
        --enable-logging \
        --disable-dap \
        --disable-examples \
        --disable-testsets
    sudo make install -j$(nproc)
    popd
    
    # libnetcdff
    curl -L --retry ${HTTP_RETRIES} https://github.com/Unidata/netcdf-fortran/archive/v${NETCDF_FORTRAN_VERSION}.tar.gz | tar xz
    pushd netcdf-fortran-${NETCDF_FORTRAN_VERSION}
    if [ "$(lsb_release -i -s)" == "CentOS" ]; then
        export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib
    fi
    ./configure --prefix=/usr
    sudo make install -j$(nproc)
    popd

    if [[ $MODE == dm* ]]; then
        # mpich
        curl -L --retry ${HTTP_RETRIES} https://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz | tar xz
        pushd mpich-${MPICH_VERSION}
        # gcc 10 work-around
        mpich_flags="FFLAGS=-fallow-argument-mismatch"
        ./configure --prefix=/usr --disable-cxx --with-device=ch3 $mpich_flags
        sudo make install -j$(nproc)
        popd
    fi

    nc-config --all
    nf-config --all || true

elif [ "$(uname)" == "Darwin" ]; then

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

    # re-install gfortran, otherwise mpif90 cannot find it
    brew uninstall --ignore-dependencies --force gcc

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

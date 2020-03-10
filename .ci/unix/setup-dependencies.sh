#!/usr/bin/env bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

SCRIPTDIR=$(dirname "$0")

source $SCRIPTDIR/retry.sh

HTTP_RETRIES=3

if [ "$(uname)" == "Linux" ]; then

    if [ "$(lsb_release -i -s)" == "Ubuntu" ]; then
        echo "APT::Acquire::Retries \"${HTTP_RETRIES}\";" | sudo tee /etc/apt/apt.conf.d/80-retries
        sudo apt-get update
        sudo apt-get install -y software-properties-common curl cmake
    fi

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
    elif [ "$(lsb_release -i -s)" == "Ubuntu" ]; then
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
            curl -L --retry ${HTTP_RETRIES} https://github.com/mdadams/jasper/archive/version-2.0.14.tar.gz | tar xz
            cd jasper-version-2.0.14/build/
            cmake -DCMAKE_INSTALL_PREFIX=/usr ..
            sudo make install
        fi

        # Need to build netcdf-fortran manually as the Fortran compiler versions have to match.
        cd /tmp
        curl -L --retry ${HTTP_RETRIES} https://github.com/Unidata/netcdf-fortran/archive/v4.4.4.tar.gz | tar xz
        cd netcdf-fortran-4.4.4
        sed -i 's/ADD_SUBDIRECTORY(examples)/#ADD_SUBDIRECTORY(examples)/' CMakeLists.txt
        mkdir build && cd build
        cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr ..
        make -j 4
        sudo make install
    elif [ "$(lsb_release -i -s)" == "CentOS" ]; then
        sudo yum install -y zlib-devel libpng-devel jasper-devel libjpeg-devel xz

        curl -L --retry ${HTTP_RETRIES} https://cmake.org/files/v3.14/cmake-3.14.3-Linux-x86_64.sh -o cmake.sh
        sudo bash cmake.sh --prefix=/usr --exclude-subdir --skip-license
        rm cmake.sh

        SZIP_VERSION=2.1.1
        curl -L --retry ${HTTP_RETRIES} https://support.hdfgroup.org/ftp/lib-external/szip/${SZIP_VERSION}/src/szip-${SZIP_VERSION}.tar.gz | tar xz
        pushd szip-${SZIP_VERSION}
        ./configure --prefix=/usr
        sudo make install -j$(nproc)
        popd

        HDF5_VERSION=1.10.5
        curl -L --retry ${HTTP_RETRIES} https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-${HDF5_VERSION}/src/CMake-hdf5-${HDF5_VERSION}.tar.gz | tar xz
        pushd CMake-hdf5-${HDF5_VERSION}/hdf5-${HDF5_VERSION}
        mkdir build
        cd build
        cmake -DCMAKE_INSTALL_PREFIX=/usr \
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
        sudo make install -j$(nproc)
        # for WRF-Make
        sudo ln -s /usr/lib/libhdf5_hl_fortran.so /usr/lib/libhdf5hl_fortran.so &&
        popd

        NETCDF_C_VERSION=4.6.1
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

        NETCDF_FORTRAN_VERSION=4.4.4
        curl -L --retry ${HTTP_RETRIES} https://github.com/Unidata/netcdf-fortran/archive/v${NETCDF_FORTRAN_VERSION}.tar.gz | tar xz
        pushd netcdf-fortran-${NETCDF_FORTRAN_VERSION}
        export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib
        ./configure --prefix=/usr --enable-static
        sudo make install -j$(nproc)
        popd
    else
        echo "The environment is not recognised"
        exit 1
    fi

    if [ $BUILD_SYSTEM == 'Make' ]; then
        if [ "$(lsb_release -i -s)" == "Ubuntu" ]; then
            sudo apt-get install -y csh m4 libhdf5-serial-dev
        elif [ "$(lsb_release -i -s)" == "CentOS" ]; then
            sudo yum install -y tcsh m4
            sudo ln -sf $(which cpp) /lib/cpp
        fi
    fi

    if [[ $MODE == dm* ]]; then
        if [ "$(lsb_release -c -s)" == "trusty" ]; then
            sudo apt-get install -y libmpich-dev
        else
            # Need to build mpich manually as the Fortran compiler versions have to match.
            MPICH_VERSION=3.2.1
            cd /tmp
            curl -L --retry ${HTTP_RETRIES} https://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz | tar xz
            cd mpich-${MPICH_VERSION}
            ./configure --prefix=/usr
            sudo make install -j$(nproc)
        fi
    fi

    nc-config --all
    nf-config --all || true

elif [ "$(uname)" == "Darwin" ]; then

    # If c++ is already present on the system, homebrew fails to install gcc.
    # Use the `-rf` flags to recursively remove dir/files without
    # prompting for errors if c++ is not present.
    rm -rf /usr/local/include/c++

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

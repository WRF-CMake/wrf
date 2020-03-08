#!/usr/bin/env bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

SCRIPTDIR=$(dirname "$0")
cd $SCRIPTDIR/../..

if [ $BUILD_SYSTEM == 'CMake' ]; then

    mkdir build && cd build
    cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=install \
          -DENABLE_GRIB1=${GRIB1} -DENABLE_GRIB2=${GRIB2} -DMODE=${MODE} -DNESTING=${NESTING} \
          -DUSE_REAL8=${REAL8} \
          -DDEBUG_ARCH=ON -DDEBUG_GLOBAL_DEFINITIONS=ON -LA ..
    
    # It sometimes happens that the compiler runs out of memory due to parallel compilation.
    # The construction below means "try with 2 cores, and if it fails, try again with 1 core".
    export VERBOSE=1
    cmake --build . --target install -- -j2 \
        || cmake --build . --target install \
        || cmake --build . --target install

elif [ $BUILD_SYSTEM == 'Make' ]; then

    # The config options below are hard-coded for gcc/gfortran,
    # let's check if another compiler was requested.
    if [[ ! $CC == gcc* ]]; then
        echo "Unsupported CC: $CC"
        exit 1
    fi
    if [[ ! $FC == gfortran* ]]; then
        echo "Unsupported FC: $FC"
        exit 1
    fi

    # On macOS we use Homebrew which installs gcc/gfortran only with a version
    # suffix (gcc-8 etc.). This is because macOS has gcc already pointing to the system clang.
    # Since we want to keep the arch/ files as they are, we create a symlink
    # to the Homebrew variants and put them in PATH before everything else.
    if [[ ! $CC == gcc ]]; then
        mkdir -p compilers
        ln -sf $(which $CC) compilers/gcc
        ln -sf $(which $FC) compilers/gfortran
        export PATH=$(pwd)/compilers:$PATH
    fi

    # WRF does not use CC/FC, so let's check what gcc/gfortran actually points to.
    which gcc
    gcc --version
    which gfortran
    gfortran --version

    export NETCDF4=1 # Compile with netCDF-4 support
    export WRF_EM_CORE=1 # Select ARW core

    if [[ $BUILD_TYPE == 'Debug' ]]; then
        debug=-d
    else
        debug=
    fi

    if [[ "$REAL8" == '1' ]]; then
        real8=-r8
    else
        real8=
    fi

    if [ "$(uname)" == "Linux" ]; then

        case $MODE in
            serial) cfg=32 ;;
            smpar)  cfg=33 ;;
            dmpar)  cfg=34 ;;
            dm_sm)  cfg=35 ;;
            *) echo "Invalid: $MODE"; exit 1 ;;
        esac

        if [ "$(lsb_release -c -s)" == "trusty" -o "$(lsb_release -i -s)" == "CentOS" ]; then
            export HDF5=/usr
            export NETCDF=/usr
        else
            # Need to create symlinked folder hierarchy that WRF expects...
            mkdir netcdf
            ln -s /usr/include netcdf/include
            ln -s /usr/lib/x86_64-linux-gnu netcdf/lib

            export HDF5=/usr/lib/x86_64-linux-gnu/hdf5/serial
            export NETCDF=`pwd`/netcdf
        fi

    elif [ "$(uname)" == "Darwin" ]; then

        case $MODE in
            serial) cfg=15 ;;
            smpar)  cfg=16 ;;
            dmpar)  cfg=17 ;;
            dm_sm)  cfg=18 ;;
            *) echo "Invalid: $MODE"; exit 1 ;;
        esac

        export HDF5=$(brew --prefix hdf5)

        # macOS doesn't support "readlink -f" and brew's coreutils provides a replacement called greadlink.
        # We use readlink to get the absolute path of the netCDF library folder as WRF's setup scripts
        # can't handle symlinks properly.
        export NETCDF=$(greadlink -f $(brew --prefix netcdf)) # see comment above about greadlink

    else
        echo "Unknown OS: $(uname)"
        exit 1
    fi

    # 1 = basic nesting
    echo "./configure $debug $real8 <<< $cfg\n1\n"
    ./configure $debug $real8 <<< $cfg$'\n1\n'

    echo "==== configure.wrf ===="
    cat configure.wrf
    echo "==== end configure.wrf ===="

    echo "./compile em_real"
    ./compile em_real

    if [ ! -f main/wrf.exe ]; then
        # Try again in case we ran out of memory, this time without parallel compilation.
        export J=
        ./compile em_real
    fi

    if [ ! -f main/wrf.exe ]; then
        # Last chance.
        ./compile em_real
    fi

    if [ ! -f main/wrf.exe ]; then
        exit 1
    fi

else
    echo "Unknown build system: $BUILD_SYSTEM"
    exit 1
fi

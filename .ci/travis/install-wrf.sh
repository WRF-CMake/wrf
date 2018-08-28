#!/bin/bash

# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

if [ $SYSTEM == "cmake" ]; then

    mkdir build && cd build
    cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=install \
          -DENABLE_GRIB1=${GRIB1} -DENABLE_GRIB2=${GRIB2} -DMODE=${MODE} -DNESTING=${NESTING} ..
    
    # It sometimes happens that the compiler runs out of memory due to parallel compilation.
    # The construction below means "try with 2 cores, and if it fails, try again with 1 core".
    cmake --build . --target install -- -j2 \
        || cmake --build . --target install \
        || cmake --build . --target install
    
    cd ..

elif [ $SYSTEM == "make" ]; then

    export NETCDF4=1 # Compile with netCDF-4 support
    export WRF_EM_CORE=1 # Select ARW core

    if [[ $BUILD_TYPE == 'Debug' ]]; then
        debug=-d
    else
        debug=
    fi

    if [[ $TRAVIS_OS_NAME == 'linux' ]]; then

        case $MODE in
            serial) cfg=32 ;;
            dmpar)  cfg=34 ;;
            *) echo "Invalid: $MODE" ;;
        esac

        export HDF5=/usr
        export NETCDF=/usr

    elif [[ $TRAVIS_OS_NAME == 'osx' ]]; then

        case $MODE in
            serial) cfg=15 ;;
            dmpar)  cfg=17 ;;
            *) echo "Invalid: $MODE" ;;
        esac

        export HDF5=$(brew --prefix hdf5)

        # macOS doesn't support "readlink -f" and brew's coreutils provides a replacement called greadlink.
        # We use readlink to get the absolute path of the netCDF library folder as WRF's setup scripts
        # can't handle symlinks properly. Note that coreutils is already installed on Travis CI.
        export NETCDF=$(greadlink -f $(brew --prefix netcdf)) # see comment above about greadlink

    else
        echo "The environment is not recognised"
    fi

    # 1 = basic nesting
    echo "./configure $debug <<< $cfg\n1\n"
    ./configure $debug <<< $cfg$'\n1\n'

    echo "./compile em_real"
    ./compile em_real

else
    echo "Unknown system: ${system}"
    exit 1
fi
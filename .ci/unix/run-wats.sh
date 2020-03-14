#!/usr/bin/env bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

SCRIPTDIR=$(dirname "$0")
cd $SCRIPTDIR/../..

if [ "$(lsb_release -i -s)" == "CentOS" ]; then
    # CentOS uses /usr/lib64 but some manually installed dependencies end up in /usr/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib
fi

if [[ $MODE == dm* ]]; then
    mpi_flag="--mpi"
fi

if [[ $OS_NAME == macOS ]]; then
    # Work around Open MPI issue
    # https://github.com/open-mpi/ompi/issues/6518
    # https://github.com/open-mpi/ompi/issues/5798
    # https://www.mail-archive.com/devel@lists.open-mpi.org/msg20760.html
    export OMPI_MCA_btl=self,tcp
    # Disable new shared memory component of Open MPI to work around issue
    # https://github.com/open-mpi/ompi/issues/7516
    export PMIX_MCA_gds=hash
fi

if [[ $BUILD_SYSTEM == "CMake" ]]; then
    dir_suffix="build/install"
fi

python wats/wats/main.py run \
    --mode $WATS_MODE \
    --wrf-dir ./$dir_suffix \
    --wps-dir ../WPS/$dir_suffix \
    --wps-case-output-dir wats_wps_outputs/00 \
    --work-dir wats_work \
    $mpi_flag

#!/bin/bash

# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

# FIXME currently non-functional due to https://github.com/Microsoft/Microsoft-MPI/issues/7

mkdir /tmp/msmpi && cd /tmp/msmpi
cp "$MSMPI_INC/mpi.h" $MINGW_PREFIX/include
cp "$MSMPI_INC/mpif.h" $MINGW_PREFIX/include
cp "$MSMPI_INC/x64/mpifptr.h" $MINGW_PREFIX/include
gfortran -c -fno-range-check -I$MINGW_PREFIX/include "$MSMPI_INC/mpi.f90"
cp mpi.mod $MINGW_PREFIX/include
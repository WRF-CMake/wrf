#!/bin/bash

# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

mkdir /tmp/msmpi && cd /tmp/msmpi
cp "$MSMPI_INC"/mpi.h .
sed -i '1s/^/#include <stdint.h>\n/' mpi.h # for __int64 type
cp mpi.h $MINGW_PREFIX/include
cpp -P -nostdinc -traditional-cpp -DINT_PTR_KIND\(\)=8 "$MSMPI_INC/mpif.h" > $MINGW_PREFIX/include/mpif.h
cp "$MSMPI_INC/mpi.f90" mpi.F90
cp "$MSMPI_INC/x64/mpifptr.h" $MINGW_PREFIX/include
gfortran -c -fno-range-check -I$MINGW_PREFIX/include -DINT_PTR_KIND\(\)=8 mpi.F90
cp mpi.mod $MINGW_PREFIX/include
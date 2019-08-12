#!/bin/bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

mkdir /tmp/mpi_test && cd /tmp/mpi_test
# can run with and without MPI
wget https://raw.githubusercontent.com/wesleykendall/mpitutorial/gh-pages/tutorials/mpi-hello-world/code/mpi_hello_world.c
# checks if MPI launches 2 processes
wget https://raw.githubusercontent.com/coderefinery/autocmake/c5057f8aee65/test/fc_mpi/src/example.F90
gcc mpi_hello_world.c -D_WIN64 -lmsmpi -L"$MSMPI_LIB64" -o mpi_hello
gfortran -o example1 example.F90 -fno-range-check -lmsmpifec -lmsmpi -L"$MSMPI_LIB64" -I$MINGW_PREFIX/include
gfortran -o example2 -DUSE_MPI_MODULE example.F90 -fno-range-check -lmsmpifec -lmsmpi -L"$MSMPI_LIB64" -I$MINGW_PREFIX/include
./mpi_hello # 1 process
export PATH="$MSMPI_BIN":$PATH
mpiexec -n 4 mpi_hello.exe
mpiexec -n 2 example1.exe
mpiexec -n 2 example2.exe
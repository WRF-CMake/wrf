# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(CC gcc)
set(FC gfortran)

set(C_debug "-g")
set(C_optimized "-O3")

set(Fortran_debug "-g -fbacktrace -ggdb")
set(Fortran_optimized "-O2 -ftree-vectorize -funroll-loops")
set(Fortran_checked "-fcheck=bounds,do,mem,pointer -ffpe-trap=invalid,zero,overflow")
set(Fortran_preprocess "-cpp")
set(Fortran_io "-fconvert=big-endian -frecord-marker=4")
set(Fortran_other "-ffree-line-length-none -DNONSTANDARD_SYSTEM_SUBR")

set(linker "-Wl,--stack,0x64000000")
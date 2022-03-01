# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(checked "-fcheck=bounds,do,mem,pointer")
set(preprocess "-cpp")
set(io "-fconvert=big-endian -frecord-marker=4")
set(promotion "-fdefault-real-8")
set(other "${other} -ffree-line-length-none")
if (CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL 10)
    set(other "${other} -fallow-argument-mismatch -fallow-invalid-boz")
endif()
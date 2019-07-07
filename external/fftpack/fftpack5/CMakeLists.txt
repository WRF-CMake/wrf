# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

file(GLOB FFT_SRC RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.F)

# Must be static as it has a cyclic dependency with frame.
add_library(fftpack STATIC ${FFT_SRC})

set_property(TARGET fftpack PROPERTY Fortran_FORMAT FREE)

wrf_export_library(fftpack)
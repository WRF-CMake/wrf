# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

# Static non-public helper library only needed by io_int library.
add_library(mman-win32 STATIC
    mman.c
    mman.h
)

wrf_export_headers(mman-win32)
wrf_export_library(mman-win32)
# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)

# MSVC does not allow mixing programming languages in one library.
add_library(bacio_c STATIC
	bacio.v1.3.c
	baciof.h
	clib.h
)

# Static non-public helper library only needed by io_grib2 library.
add_library(bacio STATIC
	baciof.F
)

set_property(TARGET io_grib_share PROPERTY Fortran_FORMAT FIXED)

target_link_libraries(bacio
	bacio_c
	io_grib_share
)

wrf_export_library(bacio)
wrf_export_library(bacio_c)
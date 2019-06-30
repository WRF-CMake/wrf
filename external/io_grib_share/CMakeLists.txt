# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

# MSVC does not allow mixing programming languages in one library.
add_library(io_grib_share_c STATIC
    get_region_center.c
    gridnav.c
    open_file.c
)

# Must be static as it has a cyclic dependency with frame.
add_library(io_grib_share STATIC
    io_grib_share.F
)

target_link_libraries(io_grib_share
    io_grib_share_c
)

# TODO why is this not working??
#set_property(TARGET io_grib_share PROPERTY Fortran_FORMAT FREE)
set_property(SOURCE io_grib_share.F PROPERTY Fortran_FORMAT FREE)

wrf_export_library(io_grib_share)
wrf_export_library(io_grib_share_c)

wrf_export_headers(io_grib_share)

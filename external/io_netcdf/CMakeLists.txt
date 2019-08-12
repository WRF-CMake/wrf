# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

include_directories(
    ${NETCDF_INCLUDE_DIRS}
    ../ioapi_share
)

# Must be static as it has a cyclic dependency with frame.
add_library(io_netcdf STATIC
    wrf_io.F90
    field_routines.F90
    module_wrfsi_static.F90
    ext_ncd_get_dom_ti.code
    ext_ncd_get_var_td.code
    ext_ncd_get_var_ti.code
    ext_ncd_put_dom_ti.code
    ext_ncd_put_var_td.code
    ext_ncd_put_var_ti.code
    transpose.code
)

set_property(TARGET io_netcdf PROPERTY Fortran_FORMAT FREE)

target_link_libraries(io_netcdf
    ${NETCDF_LIBRARIES}
)

wrf_export_library(io_netcdf)
# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

add_subdirectory(grib1_util)
add_subdirectory(MEL_grib1)
add_subdirectory(WGRIB)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)

# MSVC does not allow mixing programming languages in one library.
add_library(io_grib1_c STATIC
	grib1_routines.c
	grib1_routines.h
	gribmap.c
	gribmap.h
	trim.c
)

target_link_libraries(io_grib1_c
	grib1_util
	io_grib_share
)

# Must be static as it has a cyclic dependency with frame.
add_library(io_grib1 STATIC
	io_grib1.F
)

set_property(TARGET io_grib1 PROPERTY Fortran_FORMAT FREE)

target_link_libraries(io_grib1
	io_grib1_c
)

wrf_export_library(io_grib1)
wrf_export_library(io_grib1_c)

# tests
if(BUILD_TESTING)
	add_executable(test_grib1_routines test_grib1_routines.F)
	set_property(TARGET test_grib1_routines PROPERTY Fortran_FORMAT FREE)
	target_link_libraries(test_grib1_routines io_grib1)
	add_test(grib1_routines test_grib1_routines)
endif()


# TODO tests broken (needs source code fixes)
# test_gribmap.F90:(.text+0x1b): undefined reference to `get_grib1_table_info_size_'
# test_gribmap.F90:(.text+0x10c): undefined reference to `load_grib1_table_info_'
# load_grib1_table_info does not exist, but LOAD_GRIB1_TABLES
# also, ISO_C_BINDING should be used to interface with C
#add_executable(test_gribmap test_gribmap.F90)
#target_link_libraries(test_gribmap io_grib1)

# test_grid_info.F90:(.text+0x1e): undefined reference to `get_grib1_table_info_size_'
# test_grid_info.F90:(.text+0x115): undefined reference to `load_grib1_table_info_'
#add_executable(test_grid_info test_grid_info.F90)
#target_link_libraries(test_grid_info io_grib1)

#add_executable(test_io_grib1 test_io_grib1.F)
#target_link_libraries(test_io_grib1 io_grib1 frame)
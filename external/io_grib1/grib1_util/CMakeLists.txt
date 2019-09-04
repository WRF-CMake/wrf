# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# Static non-public helper library only needed by io_grib1 library.
add_library(grib1_util STATIC
	alloc_2d.c
	alloc_2d.h
	cfortran.h
	read_grib.c
	read_grib.h
	write_grib.c
)

target_link_libraries(grib1_util MEL_grib1)

wrf_export_library(grib1_util)
wrf_export_headers(grib1_util)

if(BUILD_TESTING)
	add_executable(test_advance_time_str test_advance_time_str.c)
	target_link_libraries(test_advance_time_str grib1_util)
	add_test(advance_time_str test_advance_time_str)

	add_executable(test_rg_gribmap test_rg_gribmap.c)
	target_link_libraries(test_rg_gribmap grib1_util)
	add_test(rg_gribmap test_rg_gribmap)
endif()

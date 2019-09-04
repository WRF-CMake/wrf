# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

add_subdirectory(g2lib)
add_subdirectory(bacio-1.3)

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)

# Must be static as it has a cyclic dependency with frame.
add_library(io_grib2 STATIC
	grib2tbls_types.F
	io_grib2.F
	read_grib2map.F
	test_read_grib2map.F
)

set_property(TARGET io_grib2 PROPERTY Fortran_FORMAT FREE)

target_link_libraries(io_grib2
	io_grib_share
	g2lib
	bacio
)

wrf_export_library(io_grib2)

if(BUILD_TESTING)
	add_executable(test_read_grib2map test_read_grib2map.F)
	target_link_libraries(test_read_grib2map io_grib2)
	add_test(read_grib2map test_read_grib2map)
endif()
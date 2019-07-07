# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

# MSVC does not allow mixing programming languages in one library.
add_library(rsl_lite_c STATIC
	c_code.c
	buf_for_proc.c
	rsl_malloc.c
	rsl_bcast.c
	task_for_point.c
	period.c
	swap.c
	cycle.c
	rsl_lite.h
)

if (WIN32)
	target_link_libraries(rsl_lite_c Ws2_32)
endif()

add_library(rsl_lite STATIC
	f_pack.F90
	f_xpose.F90
)

set_property(TARGET rsl_lite PROPERTY Fortran_FORMAT FREE)

target_link_libraries(rsl_lite rsl_lite_c)

wrf_enable_mpi(rsl_lite Fortran)
wrf_enable_mpi(rsl_lite_c C)
wrf_export_library(rsl_lite)
wrf_export_library(rsl_lite_c)

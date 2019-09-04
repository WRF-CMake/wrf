# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

include(CheckFunctionExists)

# Static non-public helper library only needed by io_grib1 library.
add_library(MEL_grib1 STATIC
	apply_bitmap.c
	display_gribhdr.c
	dprints.h
	FTP_getfile.c
	gbyte.c
	grib_dec.c
	grib_enc.c
	gribfuncs.h
	gribgetbds.c
	gribgetbms.c
	gribgetgds.c
	gribgetpds.c
	grib.h
	gribhdr2file.c
	grib_lookup.h
	gribputbds.c
	gribputgds.c
	gribputpds.c
	grib_seek.c
	grib_uthin.c
	hdr_print.c
	init_dec_struct.c
	init_enc_struct.c
	init_gribhdr.c
	init_struct.c
	input.h
	isdb.h
	ld_dec_lookup.c
	ld_enc_input.c
	ld_enc_lookup.c
	ld_grib_origctrs.c
	make_default_grbfn.c
	make_grib_log.c
	map_lvl.c
	map_parm.c
	pack_spatial.c
	prt_badmsg.c
	prt_inp_struct.c
	set_bytes.c
	swap.c
	upd_child_errmsg.c
)

# link math library if needed
CHECK_FUNCTION_EXISTS(pow POW_FUNC_FOUND)
if(NOT POW_FUNC_FOUND)
	target_link_libraries(MEL_grib1 m)
endif()

wrf_export_library(MEL_grib1)
wrf_export_headers(MEL_grib1)

if(BUILD_TESTING)
	add_executable(test_set_bytes test_set_bytes.c)
	target_link_libraries(test_set_bytes MEL_grib1)
	add_test(set_bytes test_set_bytes)
endif()
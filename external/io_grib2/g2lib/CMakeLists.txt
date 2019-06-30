# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

include_directories(
	${JASPER_INCLUDE_DIRS}
	${PNG_INCLUDE_DIRS}
	${ZLIB_INCLUDE_DIRS}
)

add_definitions(-DUSE_JPEG2000 -DUSE_PNG)

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)

# We force `g2lib` to be statically linked as the subroutines `R63W72` and `W3FI71`
# are part of the WPS source code only (`WPS/ungrib/src/ngl/w3`).
# By default, we use the `--no-undefined` flag when dynamically linking files
# so that the linker can explicitly check if all the library references can
# be resolved. As the subroutines `R63W72` and `W3FI71` are not part of this project
# we need to use static linking.
# Note that the WRF executables build fine anyway, which suggests that the routines
# calling those two routines are not used in any WRF code.

# MSVC does not allow mixing programming languages in one library.
add_library(g2lib_c STATIC
	dec_jpeg2000.c
	dec_png.c
	enc_jpeg2000.c
	enc_png.c
	mova2i.c
)

target_link_libraries(g2lib_c
	${JASPER_LIBRARIES}
	${PNG_LIBRARIES}
	${ZLIB_LIBRARIES}
)

add_library(g2lib STATIC
	addfield.F
	addgrid.F
	addlocal.F
	cmplxpack.F
	compack.F
	comunpack.F
	drstemplates.F
	g2grids.F
	gb_info.F
	gbytesc.F
	gdt2gds.F
	getdim.F
	getfield.F
	getg2i.F
	getg2ir.F
	getgb2.F
	getgb2l.F
	getgb2p.F
	getgb2r.F
	getgb2rp.F
	getgb2s.F
	getidx.F
	getlocal.F
	getpoly.F
	gettemplates.F
	gf_free.F
	gf_getfld.F
	gf_unpack1.F
	gf_unpack2.F
	gf_unpack3.F
	gf_unpack4.F
	gf_unpack5.F
	gf_unpack6.F
	gf_unpack7.F
	gribcreate.F
	gribend.F
	gribinfo.F
	gribmod.F
	gridtemplates.F
	ixgb2.F
	jpcpack.F
	jpcunpack.F
	misspack.F
	mkieee.F
	pack_gp.F
	params.F
	pdstemplates.F
	pngpack.F
	pngunpack.F
	proto.h
	putgb2.F
	rdieee.F
	realloc.F
	reduce.F
	simpack.F
	simunpack.F
	skgb.F
	specpack.F
	specunpack.F
)

set_property(TARGET g2lib PROPERTY Fortran_FORMAT FIXED)

target_link_libraries(g2lib
	g2lib_c
	io_grib_share
	bacio
)

wrf_export_library(g2lib)
wrf_export_library(g2lib_c)

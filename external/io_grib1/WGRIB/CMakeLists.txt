# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_executable(WGRIB
	bds.h
	BDSunpk.c
	bms.h
	cnames.c
	cnames.h
	cptectable_254.c
	dwdtable_002.c
	dwdtable_201.c
	dwdtable_202.c
	dwdtable_203.c
	ec_ext.c
	ectable_128.c
	ectable_129.c
	ectable_130.c
	ectable_131.c
	ectable_140.c
	ectable_150.c
	ectable_151.c
	ectable_160.c
	ectable_170.c
	ectable_180.c
	ensemble.c
	flt2ieee.c
	gds_grid.c
	gds.h
	grib.h
	gribtable.c
	ibm2flt.c
	intpower.c
	levels.c
	missing.c
	nceptab_129.c
	nceptab_130.c
	nceptab_131.c
	nceptable_opn.c
	nceptable_reanal.c
	ombtable.c
	pds4.h
	PDS_date.c
	PDStimes.c
	readgrib.c
	seekgrib.c
	wgrib_main.c
	wrtieee.c
)

install(TARGETS WGRIB
	RUNTIME DESTINATION main
)
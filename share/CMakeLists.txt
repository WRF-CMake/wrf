# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)

include_directories(
	${NETCDF_F77_INCLUDE_DIR}
	${RPC_INCLUDE_DIR}

	# Included to make wrf_io_flags.h available.
	# Note that the Makefile system rewrites that file if REAL promotion was requested.
	# This is not supported currently.
	../external/ioapi_share
)

# MSVC does not allow mixing programming languages in one library.
add_library(share_c STATIC
	landread.c
	bobrand.c
	setfeenv.c
)

target_link_libraries(share_c ${RPC_LIBRARIES})

# share/ has lots of cyclic dependencies with dyn_em/ and can only be built as static library.
add_library(share STATIC
	module_model_constants.F
	module_bc_time_utilities.F
	module_get_file_names.F
	module_compute_geop.F
	module_check_a_mundo.F
	module_random.F
	module_llxy.F
	module_interp_nmm.F
	module_interp_store.F
	module_string_tools.F
	module_MPP.F
	module_date_time.F
	module_bc.F
	module_io_wrf.F
	module_soil_pre.F
	module_io_domain.F
	module_optional_input.F
	input_wrf.F
	output_wrf.F
	wrf_bdyout.F
	wrf_bdyin.F
	dfi.F
	mediation_integrate.F
	mediation_wrfmain.F
	solve_interface.F
	mediation_interp_domain.F
	mediation_force_domain.F
	mediation_feedback_domain.F
	start_domain.F
	init_modules.F
	set_timekeeping.F
	interp_fcn.F
	sint.F
	wrf_ext_write_field.F
	wrf_ext_read_field.F
	wrf_tsin.F
	track_driver.F
	track_input.F
	module_trajectory.F
	wrf_timeseries.F
	wrf_fddaobs_in.F
	mediation_nest_move.F
)

set_property(TARGET share PROPERTY Fortran_FORMAT FREE)

target_link_libraries(share
	${NETCDF_F77_LIBRARIES}
	share_c
	frame
	io_int
)

target_include_directories(share
	INTERFACE ${CMAKE_Fortran_MODULE_DIRECTORY}
)

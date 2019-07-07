# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

if (USE_RSL_LITE)
	configure_file(../external/RSL_LITE/gen_comms.c gen_comms.c COPYONLY)
else()
	configure_file(gen_comms.stub gen_comms.c COPYONLY)
endif()

add_executable(registry
	registry.c
	my_strtok.c
	reg_parse.c
	data.c
	type.c
	misc.c
	gen_defs.c
	gen_allocs.c
	gen_mod_state_descr.c
	gen_scalar_indices.c
	gen_args.c
	gen_config.c
	sym.c
	symtab_gen.c
	gen_irr_diag.c
	gen_model_data_ord.c
	gen_interp.c
	gen_comms.c
	gen_scalar_derefs.c
	set_dim_strs.c
	gen_wrf_io.c
	gen_streams.c
)

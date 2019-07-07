# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)

# CMake doesn't understand preprocessor expressions with ()-enclosed blocks when determining dependencies and defined modules.
# For the file module_advect_em.F this would lead to incorrect module detection, so we patch the file to help CMake out.
# See https://gitlab.kitware.com/cmake/cmake/issues/17398 for details.
file(READ module_advect_em.F module_advect_em_original)
string(REPLACE "#if ( defined(ADVECT_KERNEL) )" "#ifdef ADVECT_KERNEL" module_advect_em_patched ${module_advect_em_original})
string(REPLACE "#elif ( ! defined(ADVECT_KERNEL) )" "#else" module_advect_em_patched ${module_advect_em_patched})
if (module_advect_em_original STREQUAL module_advect_em_patched)
	message(FATAL_ERROR "Could not patch module_advect_em.F. Did the file change?")
endif()
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/module_advect_em.F ${module_advect_em_patched})

add_library(dyn_em STATIC
	${CMAKE_CURRENT_BINARY_DIR}/module_advect_em.F
	module_diffusion_em.F
	module_small_step_em.F
	module_big_step_utilities_em.F
	module_em.F
	module_solvedebug_em.F
	module_bc_em.F
	module_init_utilities.F
	module_wps_io_arw.F
	module_damping_em.F
	module_polarfft.F
	module_force_scm.F
	module_first_rk_step_part1.F
	module_first_rk_step_part2.F
	module_avgflx_em.F
	module_sfs_nba.F
	module_convtrans_prep.F
	module_sfs_driver.F
	module_stoch.F
	module_after_all_rk_steps.F
	init_modules_em.F
	solve_em.F
	start_em.F
	shift_domain_em.F
	couple_or_uncouple_em.F
	nest_init_utils.F
	adapt_timestep_em.F
	interp_domain_em.F
)

set_property(TARGET dyn_em PROPERTY Fortran_FORMAT FREE)

target_link_libraries(dyn_em
	fftpack
	share
	phys
)

target_include_directories(dyn_em
	INTERFACE ${CMAKE_Fortran_MODULE_DIRECTORY}
)

wrf_enable_mpi(dyn_em Fortran)
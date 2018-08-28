# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

# real
add_executable(real_em
	real_em.F
	# The 'case' module is not part of the dyn_em library and hence is included here.
	../dyn_em/module_initialize_real.F
	${CMAKE_BINARY_DIR}/inc/actual_new_args.inc
)

set_property(TARGET real_em PROPERTY Fortran_FORMAT FREE)
set_property(TARGET real_em PROPERTY OUTPUT_NAME "real")

set_source_files_properties(${CMAKE_BINARY_DIR}/inc/actual_new_args.inc PROPERTIES GENERATED 1)
add_dependencies(real_em generate_inc)

target_link_libraries(real_em ${WRF_LIBRARIES})

install( TARGETS real_em
	RUNTIME DESTINATION ${BIN_INSTALL_DIR}
)

# ideal
set(ideal_cases
	ideal fire heldsuarez scm_xy tropical_cyclone
)
foreach(ideal_case ${ideal_cases})
# FIXME CMake apparently can't handle multiple files which use the same module name, as is the case with module_initialize_*.F
#    -> likely leads to a race condition as the temporary .mod0 files are stored in the same folder (?)
#    -> restarting the build also doesn't help in this case
# [ 99%] Building Fortran object main/CMakeFiles/ideal_em_fire.dir/__/dyn_em/module_initialize_fire.F.o
# [ 99%] Building Fortran object main/CMakeFiles/ideal_em_ideal.dir/__/dyn_em/module_initialize_ideal.F.o
# f951: Fatal Error: Can't rename module file 'module_initialize_ideal.mod0' to 'module_initialize_ideal.mod': No such file or directory
	add_executable(ideal_em_${ideal_case}
		ideal_em.F
		../dyn_em/module_initialize_${ideal_case}.F
		${CMAKE_BINARY_DIR}/inc/actual_new_args.inc
	)

	if (ideal_case STREQUAL "ideal")
		set(output_name "ideal")
	else()
		set(output_name "ideal_${ideal_case}")
	endif()

	set_property(TARGET ideal_em_${ideal_case} PROPERTY Fortran_FORMAT FREE)
	set_property(TARGET ideal_em_${ideal_case} PROPERTY OUTPUT_NAME ${output_name})

	add_dependencies(ideal_em_${ideal_case} generate_inc)

	target_link_libraries(ideal_em_${ideal_case} ${WRF_LIBRARIES})

	install( TARGETS ideal_em_${ideal_case}
		RUNTIME DESTINATION ${BIN_INSTALL_DIR}
	)
endforeach()

# wrf
add_executable(wrf_em
	wrf.F
	module_wrf_top.F
)

set_property(TARGET wrf_em PROPERTY Fortran_FORMAT FREE)
set_property(TARGET wrf_em PROPERTY OUTPUT_NAME "wrf")

target_link_libraries(wrf_em ${WRF_LIBRARIES})

install( TARGETS wrf_em
	RUNTIME DESTINATION ${BIN_INSTALL_DIR}
)
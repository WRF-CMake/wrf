# WRF-CMake (https://github.com/WRF-CMake/wrf).
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
add_custom_target(ideal)
set(ideal_cases
	ideal fire heldsuarez scm_xy tropical_cyclone
)
foreach(ideal_case ${ideal_cases})
	# All module_initialize_*.F files use the same "module_initialize_ideal" module name
	# which in turn results in a file "module_initialize_ideal.mod" (and during build ".mod0")
	# that by default is created in the same CMAKE_CURRENT_BINARY_DIR folder.
	# Even though we don't use the .mod file it leads to deletion/copying issues if
	# parallel compilation is enabled that are caused by race conditions. E.g.:
	# "Can't rename module file 'module_initialize_ideal.mod0' to 'module_initialize_ideal.mod': No such file or directory"
	# The line below tells CMake to use a separate folder for .mod files for each executable. 
	set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod/${ideal_case})

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

	add_dependencies(ideal ideal_em_${ideal_case})
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
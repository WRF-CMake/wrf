# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)

if (USE_RSL_LITE)
    configure_file(../external/RSL_LITE/module_dm.F module_dm.F COPYONLY)
else()
    configure_file(module_dm_stubs.F module_dm.F COPYONLY)
endif()

# nl_access_routines.F has to be preprocessed/built many times in different variants.
foreach(i RANGE 0 7)
    configure_file(nl_access_routines.F nl_get_${i}_routines.F)
    configure_file(nl_access_routines.F nl_set_${i}_routines.F)
    set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/nl_get_${i}_routines.F PROPERTIES COMPILE_DEFINITIONS "NNN=${i};NL_get_ROUTINES")
    set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/nl_set_${i}_routines.F PROPERTIES COMPILE_DEFINITIONS "NNN=${i};NL_set_ROUTINES")
    list(APPEND NL_ROUTINE_FILES
        ${CMAKE_CURRENT_BINARY_DIR}/nl_get_${i}_routines.F
        ${CMAKE_CURRENT_BINARY_DIR}/nl_set_${i}_routines.F)
endforeach()

include_directories(
    ../arch # for md_calls.inc
    ../external/ioapi_share # for wrf_status_codes.h
)

# MSVC does not allow mixing programming languages in one library.
add_library(frame_c STATIC
    pack_utils.c
    hires_timer.c
    wrf_num_bytes_between.c
    collect_on_comm.c
)

# frame/ has lots of cyclic dependencies with share/ and can only be built as static library.
add_library(frame STATIC
    ${NL_ROUTINE_FILES}
    ${CMAKE_BINARY_DIR}/frame/module_state_description.F
    ../share/module_model_constants.F
    module_driver_constants.F
    module_machine.F
    module_internal_header_util.F
    module_domain_type.F
    module_streams.F
    module_configure.F
    module_io.F
    module_domain.F
    module_alloc_space_0.F
    module_alloc_space_1.F
    module_alloc_space_2.F
    module_alloc_space_3.F
    module_alloc_space_4.F
    module_alloc_space_5.F
    module_alloc_space_6.F
    module_alloc_space_7.F
    module_alloc_space_8.F
    module_alloc_space_9.F
    module_dm.F
    module_timing.F
    module_intermediate_nmm.F
    module_nesting.F
    module_tiles.F
    module_cpl.F
    module_cpl_oasis3.F
    module_io_quilt.F
    module_quilt_outbuf_ops.F
    module_comm_nesting_dm.F
    module_comm_dm.F
    module_comm_dm_0.F
    module_comm_dm_1.F
    module_comm_dm_2.F
    module_comm_dm_3.F
    module_comm_dm_4.F
    libmassv.F
    module_integrate.F
    module_wrf_error.F
    wrf_debug.F
    wrf_shutdown.F
)

set_target_properties(frame PROPERTIES Fortran_FORMAT FREE)

set_source_files_properties(${CMAKE_BINARY_DIR}/frame/module_state_description.F PROPERTIES GENERATED 1)

add_dependencies(frame
    generate_inc
)

target_link_libraries(frame
    frame_c
    esmf_time
    io_int
)

if (USE_RSL_LITE)
    target_link_libraries(frame rsl_lite)
endif()

if (ENABLE_NETCDF)
    target_link_libraries(frame io_netcdf)
endif()

if (ENABLE_GRIB1)
    target_link_libraries(frame io_grib1)
endif()

if (ENABLE_GRIB2)
    target_link_libraries(frame io_grib2)
endif()

wrf_enable_mpi(frame Fortran)
wrf_enable_mpi(frame_c C)
wrf_export_library(frame)
wrf_export_library(frame_c)

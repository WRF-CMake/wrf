# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

function(wrf_export_library target)
    if (CMAKE_Fortran_MODULE_DIRECTORY)
        target_include_directories(${target} INTERFACE
            $<BUILD_INTERFACE:${CMAKE_Fortran_MODULE_DIRECTORY}>
        )
    endif()

    export(TARGETS ${target} NAMESPACE ${CMAKE_PROJECT_NAME}::
       APPEND FILE ${CMAKE_BINARY_DIR}/cmake/WRFTargets.cmake)
endfunction()

function(wrf_export_headers target)
    target_include_directories(${target} INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    )
endfunction()

function(wrf_enable_mpi target language)
    if (NOT ENABLE_MPI)
        return()
    endif()
    get_target_property(old_link_flags ${target} LINK_FLAGS)
    if (old_link_flags)
        set(link_flags "${old_link_flags}")
    else()
        set(link_flags "")
    endif()
    if (language STREQUAL "Fortran")
        target_link_libraries(${target} ${MPI_Fortran_LIBRARIES})
        set(link_flags "${link_flags} ${MPI_Fortran_LINK_FLAGS}")
        target_include_directories(${target} PRIVATE ${MPI_Fortran_INCLUDE_PATH})
    elseif (language STREQUAL "C")
        target_link_libraries(${target} ${MPI_C_LIBRARIES})
        set(link_flags "${link_flags} ${MPI_C_LINK_FLAGS}")
        target_include_directories(${target} PRIVATE ${MPI_C_INCLUDE_PATH})
    else()
        message(FATAL_ERROR "Unsupported MPI language: ${language}")
    endif()
    set_target_properties(${target} PROPERTIES LINK_FLAGS "${link_flags}")
endfunction()

function(wrf_try_compile)
    try_compile(${ARGV} OUTPUT_VARIABLE ${ARGV0}_OUTPUT)
    if (NOT ${ARGV0} AND DEBUG_FEATURE_TESTS)
        message("${${ARGV0}_OUTPUT}")
    endif()
    set(${ARGV0} ${${ARGV0}} PARENT_SCOPE)
endfunction()

function(wrf_try_run name)
    try_run(${name}_RUN ${name}_COMPILE ${ARGN} OUTPUT_VARIABLE ${name}_OUTPUT)
    if (${name}_RUN EQUAL 0)
        set(${name} TRUE PARENT_SCOPE)
    else()
        set(${name} FALSE PARENT_SCOPE)
        if (DEBUG_FEATURE_TESTS)
            message("${${name}_OUTPUT}")
            if (${name}_COMPILE)
                message("Exit code: ${${name}_RUN}")
            endif()
        endif()
    endif()
endfunction()
# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(../ioapi_share)

# Generate io_int_idx_tags.h by transforming Fortran parameters to C macro definitions.
file(STRINGS ../../inc/intio_tags.h lines)
set(patched "")
foreach (line ${lines})
    string(TOUPPER "${line}" line)
    string(REGEX REPLACE ".+::[ \t]*([A-Z_]+)[ \t]*=[ \t]*([0-9]+)" "\\1 \\2" line "${line}")
    set(patched "${patched}#define ${line}\n")
endforeach()
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/io_int_idx_tags.h ${patched})

# MSVC does not allow mixing programming languages in one library.
add_library(io_int_c STATIC
    ${CMAKE_CURRENT_BINARY_DIR}/io_int_idx_tags.h
    io_int_idx.c
    io_int_idx.h
)

if (WIN32)
    add_subdirectory(mman-win32)
    target_link_libraries(io_int_c mman-win32)
endif()

# Must be static as it has a cyclic dependency with frame.
add_library(io_int STATIC
    io_int.F90
    module_io_int_idx.F90
    module_io_int_read.F90

    # to not have a cyclic Fortran module dependency these files are included directly
    ../../frame/module_internal_header_util.F
    ../../frame/module_driver_constants.F
    ../../frame/module_machine.F
)

set_property(TARGET io_int PROPERTY Fortran_FORMAT FREE)

# Needed as some of the frame/ files above include the generated inc/model_data_order.inc file.
add_dependencies(io_int
    generate_inc
)

target_link_libraries(io_int io_int_c)

wrf_enable_mpi(io_int Fortran)
wrf_export_library(io_int)
wrf_export_library(io_int_c)
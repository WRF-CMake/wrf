# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(REGISTRY Registry.EM)

# Note that only those files are listed here which are referenced directly in other
# targets.
# If a target indirectly depends on a generated file (e.g. via #include) then
# that target only has to add a dependency to the 'generate_inc' target, not to
# individual generated files.
# By not explicitly listing all generated files here and in targets that indirectly depend on them
# we save ourselves lots of effort. The downside is that whenever any registry file is changed
# the CMake build folder has to be cleaned to force a rebuild.
# TODO list all generated files here to avoid stale builds and confusion
set(GEN_FILES
    actual_new_args.inc
    ../frame/module_state_description.F
)

file(GLOB REGISTRY_FILES ${CMAKE_SOURCE_DIR}/Registry/[r,R]egistry.*)

get_property(COMPILE_DEFS DIRECTORY PROPERTY COMPILE_DEFINITIONS)
foreach (def ${COMPILE_DEFS})
    if (def MATCHES "\\$")
        # ignore any generator expressions
        continue()
    endif()
    list(APPEND REGISTRY_DEFS -D${def})
endforeach()

add_custom_command(
    OUTPUT ${GEN_FILES}
    COMMAND registry -DNEW_BDYS ${REGISTRY_DEFS} ${CMAKE_BINARY_DIR}/Registry/${REGISTRY}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    DEPENDS registry ${REGISTRY_FILES}
)

foreach( gen_file ${GEN_FILES} )
    list( APPEND GEN_FILES_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${gen_file} )
endforeach()

# see https://cmake.org/Wiki/CMake_FAQ#How_can_I_add_a_dependency_to_a_source_file_which_is_generated_in_a_subdirectory.3F
add_custom_target(generate_inc DEPENDS ${GEN_FILES_DEPENDS})

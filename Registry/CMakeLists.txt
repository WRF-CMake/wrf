# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

# All registry files are copied over to the build directory.
# This is necessary as the registry tool generates an additional file Registry/io_boilerplate_temporary.inc
# and it is not possible to specify search locations of include files to the tool.
# Therefore the tool is pointed to the main registry file inside the build folder where it can locate
# the generated file as well. See inc/CMakeLists.txt for details.

file(GLOB REGISTRY_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} [r,R]egistry.*)

foreach( registry_file ${REGISTRY_FILES} )
    configure_file(${registry_file} ${registry_file} COPYONLY)
endforeach()

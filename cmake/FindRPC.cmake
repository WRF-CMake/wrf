# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

include(FindPackageHandleStandardArgs)
find_path(RPC_INCLUDE_DIR NAMES "rpc/rpc.h" PATH_SUFFIXES "tirpc")

if(RPC_INCLUDE_DIR MATCHES "/tirpc/?$")
    find_library(RPC_LIBRARY NAMES tirpc)
    set(RPC_LIBRARIES ${RPC_LIBRARY})
    find_package_handle_standard_args(RPC DEFAULT_MSG RPC_INCLUDE_DIR RPC_LIBRARY RPC_LIBRARIES)
elseif(MINGW)
    find_library(RPC_LIBRARY NAMES portablexdr)
    if (NOT RPC_LIBRARY OR NOT RPC_INCLUDE_DIR)
        message(FATAL_ERROR "portablexdr library not found. If using MSYS2, install mingw64/mingw-w64-x86_64-portablexdr.")
    endif()
    set(RPC_LIBRARIES ${RPC_LIBRARY})
    find_package_handle_standard_args(RPC DEFAULT_MSG RPC_INCLUDE_DIR RPC_LIBRARY RPC_LIBRARIES)
else()
    find_package_handle_standard_args(RPC DEFAULT_MSG RPC_INCLUDE_DIR)
endif()

mark_as_advanced(RPC_INCLUDE_DIR RPC_LIBRARY RPC_LIBRARIES)
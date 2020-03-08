# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

cmake_minimum_required(VERSION 3.1)

if (ARCH_CUSTOM)
    set(ARCH_PATH "${CMAKE_SOURCE_DIR}/cmake/arch/custom/${ARCH_CUSTOM}.cmake")
    if (NOT EXISTS "${ARCH_PATH}")
        set(ARCH_PATH "${ARCH_CUSTOM}")
    endif()
    message(STATUS "Using ${ARCH_PATH}")
    include(${ARCH_PATH})
    if (NOT DEFINED ENV{CC})
        set(CMAKE_C_COMPILER ${CC})
    endif()
    if (NOT DEFINED ENV{FC})
        set(CMAKE_Fortran_COMPILER ${FC})
    endif()
endif()

project(WRF C Fortran)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(WRFHelpers)

enable_testing()

########################
#    User options      #
########################

set(BUILD_TYPE_VALUES Debug Release RelWithDebInfo)
if (CMAKE_CONFIGURATION_TYPES) # multi-config generators like MSVC
    set(CMAKE_CONFIGURATION_TYPES ${BUILD_TYPE_VALUES} CACHE TYPE INTERNAL FORCE)
else()
    # https://github.com/llvm-mirror/llvm/blob/632c2834/CMakeLists.txt#L52-L55
    if (NOT CMAKE_BUILD_TYPE)
        message(STATUS "No build type selected, default to Release")
        set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type (default Release)" FORCE)
    endif()
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${BUILD_TYPE_VALUES})
    list (FIND BUILD_TYPE_VALUES "${CMAKE_BUILD_TYPE}" _index)
    if (${_index} EQUAL -1)
        message(FATAL_ERROR "CMAKE_BUILD_TYPE variable must be one of: ${BUILD_TYPE_VALUES} but is: ${CMAKE_BUILD_TYPE}")
    endif()
endif()

set(ARCH_CUSTOM "" CACHE STRING "Name of custom architecture configuration to use")
option(USE_REAL8 "Use double precision reals" OFF)
option(OPTIMIZE_C "Optimize C code even in Debug mode" ON)
option(ENABLE_RUNTIME_CHECKS "Enable compiler runtime checks in Release mode" OFF)
option(DEBUG_ARCH "Print arch files debug information" OFF)
option(DEBUG_GLOBAL_DEFINITIONS "Print global preprocessor definitions applied to all source files" OFF)
option(DEBUG_FEATURE_TESTS "Print debug information while running compiler feature tests" OFF)

set(NESTING "basic" CACHE STRING "Type of nesting support")
set(NESTING_VALUES none basic preset_moves vortex_following)
set_property(CACHE NESTING PROPERTY STRINGS ${NESTING_VALUES})
list (FIND NESTING_VALUES "${NESTING}" _index)
if (${_index} EQUAL -1)
    message(FATAL_ERROR "NESTING variable must be one of: ${NESTING_VALUES} but is: ${NESTING}")
endif()
if (NOT NESTING STREQUAL "none")
    set(ENABLE_NESTING ON)
endif()

set(MODE "serial" CACHE STRING "Parallelization mode (serial = no parallelization, smpar = OpenMP, dmpar = MPI, dm_sm = MPI + OpenMP)")
set(MODE_VALUES serial smpar dmpar dm_sm)
set_property(CACHE MODE PROPERTY STRINGS ${MODE_VALUES})
list (FIND MODE_VALUES "${MODE}" _index)
if (${_index} EQUAL -1)
    message(FATAL_ERROR "MODE variable must be one of: ${MODE_VALUES} but is: ${MODE}")
endif()
if (MODE STREQUAL "smpar")
    set(ENABLE_OpenMP ON)
    message(WARNING "Consider using dmpar (MPI) as WRF is not very optimized for smpar (OpenMP).")
elseif (MODE STREQUAL "dmpar")
    set(ENABLE_MPI ON)
elseif (MODE STREQUAL "dm_sm")
    set(ENABLE_MPI ON)
    set(ENABLE_OpenMP ON)
endif()

if (NOT ENABLE_MPI AND (NESTING STREQUAL "preset_moves" OR NESTING STREQUAL "vortex_following"))
    message(FATAL_ERROR "preset_moves and vortex_following nesting currently only supported with dmpar or dm_sm ")
    # The following patch for share/mediation_nest_move.F would fix the issue.
    # @@ -10,0 +11 @@ SUBROUTINE med_nest_move ( parent, nest )
    # +   USE module_dm, ONLY : wrf_dm_move_nest
    # @@ -12 +13 @@ SUBROUTINE med_nest_move ( parent, nest )
    # -   USE module_dm, ONLY : wrf_dm_move_nest,nest_task_offsets,mpi_comm_to_kid,mpi_comm_to_mom, which_kid
    # +   USE module_dm, ONLY : nest_task_offsets,mpi_comm_to_kid,mpi_comm_to_mom, which_kid

    # The concrete problem is that wrf_dm_move_nest gets called no matter what,
    # so it also has to be USEd no matter what. This is different to the other
    # imported routines like nest_task_offsets which only get called depending
    # on some preprocessor definitions (typically `#if defined(DM_PARALLEL) && ! defined(STUBMPI)`).
endif()

option(ENABLE_GRIB1 "Enable GRIB1 support" OFF)
option(ENABLE_GRIB2 "Enable GRIB2 support" OFF)

# WRF currently does not support building without NetCDF support.
# One reason is that solve_interface.F unconditionally calls trajectory_driver()
# which is only defined (in module_trajectory.F) if NetCDF is enabled.
set(ENABLE_NETCDF ON)

#########################
#    Compiler flags     #
#########################

if (NOT MINGW AND NOT UNIX)
    message(FATAL_ERROR "Unsupported operating system / toolset")
endif()

if (NOT ARCH_CUSTOM)
    set(ARCH_C_VARS debug optimized checked temps other)
    set(ARCH_Fortran_VARS debug optimized preprocess io checked promotion temps other)
    foreach (language C Fortran)
        set(ARCHS
            "${CMAKE_${language}_COMPILER_ID}"
            "${CMAKE_${language}_COMPILER_ID}_${CMAKE_SYSTEM_NAME}"
        )
        list(APPEND ARCHS "${CMAKE_${language}_COMPILER_ID}_${language}")
        if (UNIX)
            list(APPEND ARCHS "${CMAKE_${language}_COMPILER_ID}_UNIX")
            list(APPEND ARCHS "${CMAKE_${language}_COMPILER_ID}_${language}_UNIX")
        endif()
        list(APPEND ARCHS "${CMAKE_${language}_COMPILER_ID}_${language}_${CMAKE_SYSTEM_NAME}")
        foreach(ARCH ${ARCHS})
            set(ARCH_PATH "${CMAKE_SOURCE_DIR}/cmake/arch/default/${ARCH}.cmake")
            if (EXISTS ${ARCH_PATH})
                message(STATUS "Using ${ARCH_PATH} (${language})")
                foreach (var ${ARCH_${language}_VARS})
                    set(${var} "${${language}_${var}}")
                endforeach()
                include(${ARCH_PATH})
                foreach (var ${ARCH_${language}_VARS})
                    set(${language}_${var} "${${var}}")
                endforeach()
            elseif (DEBUG_ARCH)
                message("Not found: ${ARCH_PATH}")
            endif()
        endforeach()
    endforeach()
endif()

if (NOT DEFINED C_debug OR NOT DEFINED C_optimized)
    message(FATAL_ERROR "Missing or incomplete architecture files for C, 'debug' or 'optimized' variable missing")
elseif (NOT DEFINED Fortran_debug OR NOT DEFINED Fortran_optimized)
    message(FATAL_ERROR "Missing or incomplete architecture files for Fortran, 'debug' or 'optimized' variable missing")
elseif (NOT DEFINED Fortran_preprocess OR NOT DEFINED Fortran_io)
    message(FATAL_ERROR "Missing or incomplete architecture files for Fortran, 'preprocess' or 'io' variable missing")
endif()

set(CMAKE_C_FLAGS_DEBUG "${C_debug} ${C_checked}")
set(CMAKE_C_FLAGS_RELEASE "${C_optimized}")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "${C_optimized} ${C_debug}")
set(CMAKE_C_FLAGS "${C_other}")
set(CMAKE_Fortran_FLAGS_DEBUG "${Fortran_debug} ${Fortran_checked}")
set(CMAKE_Fortran_FLAGS_RELEASE "${Fortran_optimized}")
set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "${Fortran_optimized} ${Fortran_debug}")
set(CMAKE_Fortran_FLAGS "${Fortran_preprocess} ${Fortran_io} ${Fortran_other}")

if (OPTIMIZE_C)
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${C_optimized}")
endif()

if (ENABLE_RUNTIME_CHECKS)
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} ${C_checked}")
    set(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE} ${Fortran_checked}")
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} ${C_checked}")
    set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "${CMAKE_Fortran_FLAGS_RELWITHDEBINFO} ${Fortran_checked}")
endif()

if (USE_REAL8)
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${Fortran_promotion}")
endif()

if (SAVE_TEMPS)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${C_temps}")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${Fortran_temps}")
endif()

if (ENABLE_OpenMP)
    find_package(OpenMP REQUIRED)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${OpenMP_Fortran_FLAGS}")
endif()

if (ENABLE_MPI)
    if (MINGW)
        # TODO look for msmpi and headers
        set(MPI_C_INCLUDE_PATH ${MPI_INCLUDE_PATH})
        set(MPI_C_LIBRARIES ${MPI_C_LIBRARY})
        set(MPI_Fortran_INCLUDE_PATH ${MPI_INCLUDE_PATH})
        set(MPI_Fortran_LIBRARIES ${MPI_Fortran_LIBRARY} ${MPI_C_LIBRARY})
        # needed for MS MPI headers
        set(MPI_C_COMPILE_FLAGS "-D_WIN64")
        set(MPI_Fortran_COMPILE_FLAGS "-fno-range-check")
    else()
        find_package(MPI REQUIRED)
    endif()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${MPI_C_COMPILE_FLAGS}")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${MPI_Fortran_COMPILE_FLAGS}")
endif()

if (DEBUG_ARCH)
    foreach (language C Fortran)
        message("\n${language} arch variables:")
        foreach (var ${ARCH_${language}_VARS})
            message("${var} = ${${language}_${var}}")
        endforeach()
        foreach (build_type DEBUG RELEASE)
            message("\n${language} ${build_type} flags: ${CMAKE_${language}_FLAGS} ${CMAKE_${language}_FLAGS_${build_type}}")
        endforeach()
    endforeach()
endif()

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

#########################
#      Linker flags     #
#########################

if (NOT ARCH_CUSTOM)
    set(ARCHS)
    foreach (language C Fortran)
        list(APPEND ARCHS "${CMAKE_${language}_COMPILER_ID}")
        if (UNIX)
            list(APPEND ARCHS "${CMAKE_${language}_COMPILER_ID}_UNIX")
        endif()
        list(APPEND ARCHS "${CMAKE_${language}_COMPILER_ID}_${CMAKE_SYSTEM_NAME}")
    endforeach()
    list(REMOVE_DUPLICATES ARCHS)
    foreach(ARCH ${ARCHS})
        set(ARCH_PATH "${CMAKE_SOURCE_DIR}/cmake/arch/default/${ARCH}.cmake")
        if (EXISTS ${ARCH_PATH})
            message(STATUS "Using ${ARCH_PATH} (linker)")
            include(${ARCH_PATH})
        elseif (DEBUG_ARCH)
            message("Not found: ${ARCH_PATH}")
        endif()
    endforeach()
endif()

if (linker)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${linker}")
endif()

if (DEBUG_ARCH)
    message("Linker flags: ${CMAKE_EXE_LINKER_FLAGS}")
endif()

##########################
#     Include paths      #
##########################

# Nearly all targets require those two include paths, so we declare them here to avoid repetition
include_directories(
    inc
    ${CMAKE_BINARY_DIR}/inc
)

##########################
#  Package dependencies  #
##########################

if (ENABLE_NETCDF)
    find_package(NetCDF REQUIRED COMPONENTS F77 F90)

    # If we link against the static netCDF-C library (currently required on mingw64) then its
    # HDF5 dependency is not linked into the netCDF-C library (not exactly sure why).
    # Similarly, netCDF-Fortran lacks the netCDF-C dependency.
    # The following fixes that.
    STRING(REGEX MATCH ".a$" match ${NETCDF_LIBRARY})
    if (match)
        find_package(HDF5 REQUIRED COMPONENTS C HL)
        set(NETCDF_F77_LIBRARIES ${NETCDF_F77_LIBRARIES} ${NETCDF_C_LIBRARIES} ${HDF5_LIBRARIES} ${HDF5_HL_LIBRARIES})
        set(NETCDF_F99_LIBRARIES ${NETCDF_F99_LIBRARIES} ${NETCDF_C_LIBRARIES} ${HDF5_LIBRARIES} ${HDF5_HL_LIBRARIES})
        set(NETCDF_LIBRARIES ${NETCDF_LIBRARIES} ${HDF5_LIBRARIES} ${HDF5_HL_LIBRARIES})
    endif()
endif()

if (ENABLE_GRIB2)
    find_package(Jasper REQUIRED)
    find_package(PNG REQUIRED)
    find_package(ZLIB REQUIRED)
endif()

find_package(RPC)

####################################
#  Common preprocessor definitions #
####################################

if (USE_REAL8)
    set(RWORDSIZE 8)
else()
    set(RWORDSIZE 4)
endif()

# Common definitions are globally defined such that they are inherited in subfolders and their targets.
# Doing that (instead of providing definitions in a variable that subfolders may or may not use) prevents
# accidental mistakes where code still compiles but some defaults are used that are incompatible with the rest.
add_definitions(
    -Dwrfmodel
    -DEM_CORE=1
    -DDA_CORE=0
    -DNMM_CORE=0
    -DEXP_CORE=0
    -DCOAMPS_CORE=0
    -DINTIO
    -DKEEP_INT_AROUND
    -DLIMIT_ARGS
    -DBUILD_RRTMG_FAST=1
    -DSHOW_ALL_VARS_USED=0
    -DCONFIG_BUF_LEN=65536
    -DMAX_DOMAINS_F=21
    -DIWORDSIZE=4
    -DDWORDSIZE=8
    -DLWORDSIZE=4
    -DRWORDSIZE=${RWORDSIZE}
    -DMAX_HISTORY=25
    -DWRF_USE_CLM
    -DLANDREAD_STUB=1

    # See Transpose() subroutine in external/io_netcdf/wrf_io.F90.
    -DNO_M4
)

# Note for the future: CMake 3.12 added add_compile_definitions
# which is like add_definitions but supports generator expressions.
set_property(DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS
    $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:Release>>:NDEBUG>)

if (ENABLE_MPI)
    add_definitions(-DDM_PARALLEL)
    set(USE_RSL_LITE ON)
endif()

if (ENABLE_NESTING AND NOT ENABLE_MPI)
    add_definitions(-DDM_PARALLEL -DSTUBMPI)
    set(USE_RSL_LITE ON)
endif()

if (NESTING STREQUAL "preset_moves")
    add_definitions(-DMOVE_NESTS)
endif()

if (NESTING STREQUAL "vortex_following")
    add_definitions(-DMOVE_NESTS -DVORTEX_CENTER)
endif()

if (ENABLE_NETCDF)
    add_definitions(-DNETCDF -DUSE_NETCDF4_FEATURES)
endif()

if (ENABLE_GRIB1)
    add_definitions(-DGRIB1)
endif()

if (ENABLE_GRIB2)
    add_definitions(-DGRIB2)
endif()

wrf_try_compile(FORTRAN_2003_FLUSH_TEST ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}/tools/fortran_2003_flush_test.F)
wrf_try_compile(FORTRAN_2003_IEEE_TEST ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}/tools/fortran_2003_ieee_test.F)
wrf_try_compile(FORTRAN_2003_ISO_C_TEST ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}/tools/fortran_2003_iso_c_test.F)
wrf_try_compile(FORTRAN_2008_GAMMA_TEST ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}/tools/fortran_2008_gamma_test.F)

if (NOT FORTRAN_2003_FLUSH_TEST)
    wrf_try_compile(FORTRAN_2003_FFLUSH_TEST ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}/tools/fortran_2003_fflush_test.F)
    if (FORTRAN_2003_FFLUSH_TEST)
        add_definitions(-DUSE_FFLUSH)
    else()
        add_definitions(-DNO_FLUSH_SUPPORT)
    endif()
endif()

if (NOT FORTRAN_2003_IEEE_TEST)
    add_definitions(-DNO_IEEE_MODULE)
endif()

if (NOT FORTRAN_2003_ISO_C_TEST)
    add_definitions(-DNO_ISO_C_SUPPORT)
endif()

if (NOT FORTRAN_2008_GAMMA_TEST)
    add_definitions(-DNO_GAMMA_SUPPORT)
endif()

# tools/fseek_test.c uses the tools/Makefile file in its feature test but the working directory with CMake's try_run
# is always the build root folder (no matter what the bindir of try_run is set to).
# Since CMake creates a Makefile itself there in that location after configure completed we have to be careful
# to delete our temporary file again to not confuse CMake.
if (NOT EXISTS ${CMAKE_BINARY_DIR}/Makefile)
    # Temporarily create this file so that we can run the fseek tests.
    file(WRITE ${CMAKE_BINARY_DIR}/Makefile "")
    set(FSEEK_CLEANUP TRUE)
endif()
wrf_try_run(FSEEKO64_TEST ${CMAKE_BINARY_DIR}/tools/fseek_test ${CMAKE_SOURCE_DIR}/tools/fseek_test.c
    COMPILE_DEFINITIONS -DTEST_FSEEKO64)
if (FSEEKO64_TEST)
    add_definitions(-DFSEEKO64_OK)
else()
    wrf_try_run(FSEEKO_TEST ${CMAKE_BINARY_DIR}/tools/fseek_test ${CMAKE_SOURCE_DIR}/tools/fseek_test.c
        COMPILE_DEFINITIONS -DTEST_FSEEKO)
    if (FSEEKO_TEST)
        add_definitions(-DFSEEKO_OK)
    endif()
endif()
if (FSEEK_CLEANUP)
    file(REMOVE ${CMAKE_BINARY_DIR}/Makefile)
endif()

if (ENABLE_MPI)
    wrf_try_compile(MPI2_TEST ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}/tools/mpi2_test.c
        CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${MPI_C_INCLUDE_PATH}" "-DLINK_LIBRARIES=${MPI_C_LIBRARIES}")
    if (MPI2_TEST)
        add_definitions(-DMPI2_SUPPORT)
    endif()
    if (ENABLE_OpenMP)
        wrf_try_compile(MPI2_THREAD_TEST ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}/tools/mpi2_thread_test.c
            CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${MPI_C_INCLUDE_PATH}" "-DLINK_LIBRARIES=${MPI_C_LIBRARIES}")
        if (MPI2_THREAD_TEST)
            add_definitions(-DMPI2_THREAD_SUPPORT)
        endif()
    endif()
endif()

if (APPLE)
    add_definitions(-DMACOS)
endif()

if (DEBUG_GLOBAL_DEFINITIONS)
    get_directory_property(defs COMPILE_DEFINITIONS)
    message("${defs}")
endif()

#################
# Other options #
#################

# For consistency with WRF's conventions we use .exe on Linux as well.
# Note that due to a CMake bug this needs to come after any try_run call, otherwise try_run cannot
# find its executables as it builds with native suffix but locates using CMAKE_EXECUTABLE_SUFFIX.
set(CMAKE_EXECUTABLE_SUFFIX .exe)

# The folder below the INSTALL_PREFIX that contains the executables.
set(BIN_INSTALL_DIR main)

###########################
# Walk the subdirectories #
###########################

# Make sure the file exists and is empty as we append to it.
file(WRITE ${CMAKE_BINARY_DIR}/cmake/WRFTargets.cmake "")

# frame, share, phys, dyn_em all have cyclic dependencies between each other.
# This means they form one static library together which is called wrflib in WRF's Makefiles.
# The original Makefiles of those folders all add objects to that one single static library.
# The approach we take here is to create separate static libraries per folder that are then linked in to
# the main executables. This is more natural for CMake and gives us flexibility in defining
# different compile options per static library.

add_subdirectory(external)
add_subdirectory(Registry)
add_subdirectory(tools)
add_subdirectory(inc)
add_subdirectory(frame)
add_subdirectory(share)
add_subdirectory(phys)
add_subdirectory(dyn_em)

# We don't actually assemble a wrflib static library from all the separate libraries but just
# define what it would be made out of, and then link those libraries into the executables
# that need them.
set(WRF_LIBRARIES
    frame
    share
    phys
    dyn_em
)

add_subdirectory(main)
add_subdirectory(test)
add_subdirectory(cmake/post_install)

# Allow import of targets and compile options from WPS.
include(CMakePackageConfigHelpers)
configure_package_config_file(
    cmake/WRFConfig.cmake.in
    ${CMAKE_BINARY_DIR}/cmake/WRFConfig.cmake
    INSTALL_DESTINATION cmake
)

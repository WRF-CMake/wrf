# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# In Makefile a perl script is invoked which prefixes subroutine names
# with da_ if -DVAR4D is defined (which equates to 4D_DA_CORE).
# This core is not supported with CMake currently, so we ignore that case and the perl script.

# Must be static as it has a cyclic dependency with frame.
add_library(esmf_time STATIC
    ESMF_Alarm.F90
    ESMF_AlarmClock.F90
    ESMF_Base.F90
    ESMF_BaseTime.F90
    ESMF_Calendar.F90
    ESMF_Clock.F90
    ESMF_Fraction.F90
    ESMF_Macros.inc
    ESMF_Mod.F90
    ESMF_Stubs.F90
    ESMF_Time.F90
    ESMF_TimeInterval.F90
    ESMF_TimeMgr.inc
    Meat.F90
    module_symbols_util.F90
    module_utility.F90
)

set_property(TARGET esmf_time PROPERTY Fortran_FORMAT FREE)

wrf_export_library(esmf_time)

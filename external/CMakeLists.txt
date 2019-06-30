# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

add_subdirectory(io_grib_share)
if (ENABLE_GRIB1)
    add_subdirectory(io_grib1)
endif()
if (ENABLE_GRIB2)
    add_subdirectory(io_grib2)
endif()
add_subdirectory(io_int)
if (ENABLE_NETCDF)
    add_subdirectory(io_netcdf)
endif()
if (USE_RSL_LITE)
    add_subdirectory(RSL_LITE)
endif()
add_subdirectory(esmf_time_f90)
add_subdirectory(fftpack)
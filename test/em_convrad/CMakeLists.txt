# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(run_files
    README.namelist
    LANDUSE.TBL
    RRTM_DATA
    RRTMG_LW_DATA
    RRTMG_SW_DATA
    ozone.formatted
    ozone_lat.formatted
    ozone_plev.formatted
)

foreach (run_file ${run_files})
    install(FILES ${CMAKE_SOURCE_DIR}/run/${run_file} DESTINATION test/em_convrad)
endforeach()

install(FILES
    input_sounding
    namelist.input
    README.convrad
    DESTINATION test/em_convrad
)

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(run_files
    README.namelist
    RRTM_DATA
    LANDUSE.TBL
)

foreach (run_file ${run_files})
    install(FILES ${CMAKE_SOURCE_DIR}/run/${run_file} DESTINATION test/em_tropical_cyclone)
endforeach()

install(FILES
    input_sounding
    namelist.input
    README.tropical_cyclone
    DESTINATION test/em_tropical_cyclone
)
# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(run_files
    README.namelist
    RRTM_DATA
    LANDUSE.TBL
    wind-turbine-1.tbl
)

foreach (run_file ${run_files})
    install(FILES ${CMAKE_SOURCE_DIR}/run/${run_file} DESTINATION test/em_seabreeze2d_x)
endforeach()

install(FILES
    input_sounding
    namelist.input
    namelist.input.windfarm
    README.seabreeze
    DESTINATION test/em_seabreeze2d_x
)
# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(run_files
    README.namelist
    RRTM_DATA
)

foreach (run_file ${run_files})
    install(FILES ${CMAKE_SOURCE_DIR}/run/${run_file} DESTINATION test/em_b_wave)
endforeach()

install(FILES
    input_jet
    namelist.input
    namelist.input.backwards
    DESTINATION test/em_b_wave
)
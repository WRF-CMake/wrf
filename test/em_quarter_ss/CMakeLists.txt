# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(run_files
    README.namelist
    bulkdens.asc_s_0_03_0_9
    bulkradii.asc_s_0_03_0_9
    capacity.asc
    coeff_p.asc
    coeff_q.asc
    constants.asc
    kernels.asc_s_0_03_0_9
    kernels_z.asc
    masses.asc
    termvels.asc
    RRTM_DATA
)

foreach (run_file ${run_files})
    install(FILES ${CMAKE_SOURCE_DIR}/run/${run_file} DESTINATION test/em_quarter_ss)
endforeach()

install(FILES
    input_sounding
    namelist.input
    namelist.input_2to1
    namelist.input_3to1
    namelist.input_4to1
    namelist.input_5to1
    README.quarter_ss
    DESTINATION test/em_quarter_ss
)
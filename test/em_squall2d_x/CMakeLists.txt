# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

install(FILES ${CMAKE_SOURCE_DIR}/run/README.namelist DESTINATION test/em_squall2d_x)

install(FILES
    input_sounding
    namelist.input
    DESTINATION test/em_squall2d_x
)
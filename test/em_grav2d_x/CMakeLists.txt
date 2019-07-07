# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

install(FILES ${CMAKE_SOURCE_DIR}/run/README.namelist DESTINATION test/em_grav2d_x)

install(FILES
    input_sounding
    input_sounding.um=0
    input_sounding.um=20
    namelist.input
    namelist.input.100m
    namelist.input.200m
    namelist.input.400m
    README.grav2d_x
    DESTINATION test/em_grav2d_x
)
# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

install(FILES ${CMAKE_SOURCE_DIR}/run/README.namelist DESTINATION test/em_les)

install(FILES
    input_sounding
    input_sounding_free
    input_sounding_meanwind
    input_sounding_shalconv
    input_sounding.SGP
    namelist.input
    namelist.input_shalconv
    namelist.input.SGP
    README.les
    DESTINATION test/em_les
)
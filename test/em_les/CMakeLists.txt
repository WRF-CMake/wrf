# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

install(FILES ${CMAKE_SOURCE_DIR}/run/README.namelist DESTINATION test/em_les)

install(FILES
    input_sounding
    input_sounding.SGP
    input_sounding_free
    input_sounding_meanwind
    input_sounding_shalconv
    namelist.input
    namelist.input.SGP
    namelist.input_shalconv
    README.les
    DESTINATION test/em_les
)
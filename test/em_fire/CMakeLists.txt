# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

install(FILES ${CMAKE_SOURCE_DIR}/run/README.namelist DESTINATION test/em_fire)
install(FILES input_sounding_hill_simple DESTINATION test/em_fire RENAME input_sounding)
install(FILES namelist.input_hill_simple DESTINATION test/em_fire RENAME namelist.input)

install(FILES
    input_sounding_hill_simple
    input_sounding_two_fires
    namelist.fire
    namelist.fire_hill_simple
    namelist.fire_two_fires
    namelist.input_hill_simple
    namelist.input_two_fires
    README.txt
    DESTINATION test/em_fire
)
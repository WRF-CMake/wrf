# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(run_files
    README.namelist
    LANDUSE.TBL
    VEGPARM.TBL
    SOILPARM.TBL
    GENPARM.TBL
    RRTM_DATA
)

foreach (run_file ${run_files})
    install(FILES ${CMAKE_SOURCE_DIR}/run/${run_file} DESTINATION test/em_scm_xy)
endforeach()


install(FILES 
    force_ideal.nc
    forcing_file.cdl
    GABLS_II_forcing.txt
    input_soil
    input_sounding
    make_scm_forcing.ncl
    namelist.input
    README.scm
    DESTINATION test/em_scm_xy
)
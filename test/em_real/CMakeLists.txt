# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(run_files
    ETAMPNEW_DATA 
    ETAMPNEW_DATA.expanded_rain 
    RRTM_DATA 
    RRTMG_LW_DATA 
    RRTMG_SW_DATA 
    CAM_ABS_DATA 
    CAM_AEROPT_DATA 
    CAMtr_volume_mixing_ratio.RCP4.5 
    CAMtr_volume_mixing_ratio.RCP6   
    CAMtr_volume_mixing_ratio.A1B    
    CAMtr_volume_mixing_ratio.A2     
    CLM_ALB_ICE_DFS_DATA 
    CLM_ALB_ICE_DRC_DATA 
    CLM_ASM_ICE_DFS_DATA 
    CLM_ASM_ICE_DRC_DATA 
    CLM_DRDSDT0_DATA 
    CLM_EXT_ICE_DFS_DATA 
    CLM_EXT_ICE_DRC_DATA 
    CLM_KAPPA_DATA 
    CLM_TAU_DATA 
    ozone.formatted 
    ozone_lat.formatted 
    ozone_plev.formatted 
    aerosol.formatted 
    aerosol_lat.formatted 
    aerosol_lon.formatted 
    aerosol_plev.formatted 
    capacity.asc 
    coeff_p.asc 
    coeff_q.asc 
    constants.asc 
    masses.asc 
    termvels.asc 
    kernels.asc_s_0_03_0_9 
    kernels_z.asc 
    bulkdens.asc_s_0_03_0_9 
    bulkradii.asc_s_0_03_0_9 
    CCN_ACTIVATE.BIN 
    p3_lookup_table_1.dat-v4.1
    p3_lookup_table_2.dat-v4.1
    HLC.TBL
    wind-turbine-1.tbl
    ishmael-gamma-tab.bin
    ishmael-qi-qc.bin
    ishmael-qi-qr.bin
    BROADBAND_CLOUD_GODDARD.bin
    GENPARM.TBL
    LANDUSE.TBL
    SOILPARM.TBL 
    URBPARM.TBL
    VEGPARM.TBL
    MPTABLE.TBL
    tr49t67
    tr49t85
    tr67t85
    gribmap.txt
    grib2map.tbl
)

foreach (run_file ${run_files})
    install(FILES ${CMAKE_SOURCE_DIR}/run/${run_file} DESTINATION test/em_real)
endforeach()

install(FILES ${CMAKE_SOURCE_DIR}/run/CAMtr_volume_mixing_ratio.RCP8.5
    DESTINATION test/em_real
    RENAME CAMtr_volume_mixing_ratio)

install(FILES
    examples.namelist
    landFilenames
    namelist.input
    namelist.input.4km
    namelist.input.chem
    namelist.input.diags
    namelist.input.fire
    namelist.input.global
    namelist.input.jan00
    namelist.input.jun01
    namelist.input.ndown_1
    namelist.input.ndown_2
    namelist.input.ndown_3
    namelist.input.pbl-les
    namelist.input.volc
    README.grid_fdda
    README.obs_fdda
    run_1way.tar
    run_2way.tar
    run_restart.tar
    sample.txt
    wind-turbine-1.tbl
    windturbines.txt
    DESTINATION test/em_real)

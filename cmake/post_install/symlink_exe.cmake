# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

function(get_subfolders result root)
    file(GLOB children RELATIVE ${root} ${root}/*)
    set(subfolders "")
    foreach(child ${children})
        if(IS_DIRECTORY ${root}/${child})
            list(APPEND subfolders ${child})
        endif()
    endforeach()
    set(${result} ${subfolders} PARENT_SCOPE)
endfunction()

function(create_exe_symlink test_folder exe_file link_file)
    # target is a relative symlink so that the install folder is relocatable
    set(target "../../${BIN_INSTALL_DIR}/${exe_file}")
    set(link "${CMAKE_INSTALL_PREFIX}/test/${test_folder}/${link_file}")

    if (EXISTS "${link}")
        file(REMOVE "${link}")
    endif()
    if (WIN32)
        # Here we don't create a real symlink but instead a .bat shell script
        # which can be invoked the same way. Symlinks in Windows require admin
        # rights or having the Windows 10 developer mode enabled.
        file(TO_NATIVE_PATH "${target}" target_native)
        message(STATUS "creating symlink-like script ${link}.bat -> ${target}")
        file(WRITE "${link}.bat" "${target_native}")
    else()
        message(STATUS "creating symlink ${link} -> ${target}")
        execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
            ${target} ${link})
    endif()
endfunction()

get_subfolders(test_folders ${CMAKE_INSTALL_PREFIX}/test)

set(BIN_PATH "${CMAKE_INSTALL_PREFIX}/${BIN_INSTALL_DIR}")

message(STATUS "symlinking .exe files from binaries folder ${BIN_PATH} into ${CMAKE_INSTALL_PREFIX}/em_* folders")
file(GLOB exe_files RELATIVE ${BIN_PATH} ${BIN_PATH}/*.exe)

foreach (test_folder ${test_folders})
    create_exe_symlink(${test_folder} wrf.exe wrf.exe)
    if (test_folder STREQUAL "em_real")
        create_exe_symlink(${test_folder} real.exe real.exe)
    else()
        string(REPLACE "em_" "" ideal_case ${test_folder})
        if (EXISTS "${BIN_PATH}/ideal_${ideal_case}.exe")
            create_exe_symlink(${test_folder} ideal_${ideal_case}.exe ideal.exe)
        else()
            create_exe_symlink(${test_folder} ideal.exe ideal.exe)
        endif()
    endif()
endforeach()
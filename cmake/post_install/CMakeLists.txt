# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

# See https://gitlab.kitware.com/cmake/cmake/issues/17989 for why this code is in a separate file/folder.

if (WIN32)
    set(apps
        "\${CMAKE_INSTALL_PREFIX}/${BIN_INSTALL_DIR}/wrf.exe"
        "\${CMAKE_INSTALL_PREFIX}/${BIN_INSTALL_DIR}/real.exe"
        )

    # TODO For macOS, try delocate-path (https://github.com/matthew-brett/delocate)

    # This copies all necessary DLLs next to the executables.
    foreach (app ${apps})
        install(CODE "
            include(BundleUtilities)
            fixup_bundle(\"${app}\" \"\" \"\")
            ")
    endforeach()
endif()

# forward variable for following install scripts
install(CODE "set(BIN_INSTALL_DIR \"${BIN_INSTALL_DIR}\")")

install(SCRIPT symlink_exe.cmake)

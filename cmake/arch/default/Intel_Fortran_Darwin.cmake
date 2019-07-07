# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

# see https://software.intel.com/en-us/articles/ld-symbols-not-found-when-linking-library-containing-no-executable-functions
set(other "${other} -fno-common")

# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

# Default stack size on Windows/MSYS is 1MB but registry.exe needs more.
# TODO why is -Wl necessary here? CMake bug?
set(linker "-Wl,--stack,0x64000000")

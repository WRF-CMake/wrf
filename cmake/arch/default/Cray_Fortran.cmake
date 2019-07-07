# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(optimized "-O3 -hfp3")
set(checked "-R b")
set(io "-h byteswapio")
set(promotion "-s real64")
set(other "${other} -N 1023")
# WRF-CMake (https://github.com/WRF-CMake/WRF).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set(checked "-check noarg_temp_created,bounds,format,output_conversion,pointers,uninit")
set(preprocess "-fpp")
set(io "-convert big_endian -assume byterecl")
set(optimized "${optimized} -align all -fno-alias")
set(other "-fp-model precise -DNONSTANDARD_SYSTEM_FUNC")
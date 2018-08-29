# WRF-CMake [![Build status](https://ci.appveyor.com/api/projects/status/86508wximkvmf95g/branch/wrf-cmake?svg=true)](https://ci.appveyor.com/project/WRF-CMake/wrf/branch/wrf-cmake) [![Build Status](https://travis-ci.com/WRF-CMake/WRF.svg?branch=wrf-cmake)](https://travis-ci.com/WRF-CMake/WRF) 

- [What is WRF-CMake?](#what-is-wrf-cmake)
    - [Currently supported platforms](#currently-supported-platforms)
    - [Currently unsupported features](#currently-unsupported-features)
- [Installation](#installation)
    - [Pre-built binaries](#pre-built-binaries)
    - [Build from source](#build-from-source)
- [Changes to be upstreamed](#changes-to-be-upstreamed)
- [Copyright and license](#copyright-and-license)

## What is WRF-CMake?
WRF-CMake adds CMake support to the latest version of the [Advanced Research Weather Research and Forecasting](https://www.mmm.ucar.edu/weather-research-and-forecasting-model) model (here WRF, for short) with the intention of streamlining and simplifying its configuration and build process. In our view, the use of CMake provides model developers, code maintainers, and end-users with several advantages such as robust incremental rebuilds, flexible library dependency discovery, native tool-chains for Windows, macOS, and Linux with minimal external dependencies, thus increasing portability, and automatic generation of project files for different platforms.

WRF-CMake is designed to work alongside the current releases of WRF. This means that you can still compile your code using the legacy Makefiles included in WRF and WPS. In the current GitHub platform we also conduct extensive compilation and regression tests at each commit.

### Currently supported platforms
- Linux with gcc/gfortran and Intel compilers
- macOS with gcc/gfortran and Intel compilers
- Windows with MinGW-w64 and gcc/gfortran

### Currently unsupported features
- WRF-NMM (discontinued. See: https://dtcenter.org/wrf-nmm/users/)
- Configurations for special environments like supercomputers
- Promotion of Fortran's REAL to DOUBLE

## Installation

### Pre-built binaries
We currently provide WRF-CMake and WPS-CMake pre-built binary distributions for Windows only.
To download the latest releases, please see the following links:

- WRF-CMake (`serial` and `dmpar`): [https://github.com/WRF-CMake/WRF/releases](https://github.com/WRF-CMake/WRF/releases).
- WPS-CMake (`serial` and `dmpar`): [https://github.com/WRF-CMake/WPS/releases](https://github.com/WRF-CMake/WPS/releases).

To use WRF-CMake and WPS-CMake built in `dmpar`, you need to download and install Microsoft MPI — download and install `msmpisetup.exe` from [https://www.microsoft.com/en-us/download/details.aspx?id=56727](https://www.microsoft.com/en-us/download/details.aspx?id=56727).

### Build from source
To build WRF-CMake from source, please refer to the [WRF-CMake Installation page](README_CMAKE_INSTALL.md).

## Changes to be upstreamed
- `external/io_grib1/MEL_grib1/{grib_enc.c,gribputgds.c,pack_spatial.c}`: Remove redundant header includes causing symbol conflicts in Windows
- `external/io_grib2/g2lib/{dec,enc}_png.c`: Changed type 'voidp' to 'png_voidp' to make it compatible with newer libpng versions. See: https://trac.macports.org/ticket/36470
- `external/io_grib2/g2lib/enc_jpeg2000.c`: Removed redundant `image.inmem_=1;` to make it compatible with newer libjasper versions >= 1.900.25
- `external/io_grib_share/open_file.c`, `external/io_grib2/bacio-1.3/bacio.v1.3.c`, `external/io_int/io_int_idx.c`, `external/RSL_LITE/c_code.c`: Fixed file opening on Windows which is text-mode by default and has been changed to binary mode
- `external/io_netcdf/wrf_io.F90`: Added alternative `XDEX(A,B,C)` macro for systems without M4
- `external/RSL_LITE/c_code.c`: Fixed condition of preprocessing definition for `minf` to be Windows compatible
- `phys/module_sf_clm.F`: Fixed missing `IFPORT` module import needed for non-standard subroutine `abort` when using Intel Fortran
- `share/landread.c`: Fixed header includes for Windows (`io.h` instead of `unistd.h`)
- `tools/gen_{interp,irr_diag}.c`: Fixed missing function aliasing for Windows for `strcasecmp`, `rindex`, `index`
- `tools/gen_irr_diag.c`: Remove redundant `sys/resource.h` header include which would be unavailable on Windows
- `tools/registry.c`: Fixed incorrect Windows-conditional header include for `string.h` (needed in all cases, not just non-Windows)
- `var/run/crtm_coeffs`: Removed broken absolute UNIX symlink as this causes trouble with git operations in Windows

## Copyright and license
General WRF copyright and license applies for any files part of the original WRF distribution — see the [README](README) file for more details.

Additional files provided by WRF-CMake are licensed according to [LICENSE_CMAKE.txt](LICENSE_CMAKE.txt) if the relevant file contains the following header at the beginning of the file, otherwise the general WRF copyright and license applies.
```
Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.
```

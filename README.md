# WRF-CMake [![Build status Azure Pipelines](https://dev.azure.com/WRF-CMake/WRF/_apis/build/status/WRF%20(full)?branchName=wrf-cmake)](https://dev.azure.com/WRF-CMake/WRF/_build/latest?definitionId=5&branchName=wrf-cmake) [![Build status Appveyor](https://ci.appveyor.com/api/projects/status/86508wximkvmf95g/branch/wrf-cmake?svg=true)](https://ci.appveyor.com/project/WRF-CMake/wrf/branch/wrf-cmake) [![Build status Travis CI](https://travis-ci.com/WRF-CMake/WRF.svg?branch=wrf-cmake)](https://travis-ci.com/WRF-CMake/WRF)

  - [Project overview](#project-overview)
    - [Currently supported platforms](#currently-supported-platforms)
    - [Currently unsupported features](#currently-unsupported-features)
  - [Installation](#installation)
    - [Manually from source](#manually-from-source)
    - [Using Homebrew or Linuxbrew](#using-homebrew-or-linuxbrew)
    - [Binary distribution (Experimental)](#binary-distribution-experimental)
  - [Documentation](#documentation)
  - [Example usage](#example-usage)
  - [How to cite](#how-to-cite)
  - [How to contribute](#how-to-contribute)
  - [Testing framework](#testing-framework)
  - [Changes to be upstreamed](#changes-to-be-upstreamed)
  - [Copyright and license](#copyright-and-license)

## Project overview

WRF-CMake adds CMake support to the latest version of the [Advanced Research Weather Research and Forecasting](https://www.mmm.ucar.edu/weather-research-and-forecasting-model) model (here WRF, for short) with the intention of streamlining and simplifying its configuration and build process. In our view, the use of CMake provides model developers, code maintainers, and end-users with several advantages such as robust incremental rebuilds, flexible library dependency discovery, native tool-chains for Windows, macOS, and Linux with minimal external dependencies, thus increasing portability, and automatic generation of project files for different platforms.

WRF-CMake is designed to work alongside the current releases of WRF, therefore you can still compile your code using the legacy Makefiles included in WRF and WPS for any of the currently unsupported features.

For more details, please see the short summary paper [WRF-CMake: integrating CMake support into the Advanced Research WRF (ARW) modelling system](https://joss.theoj.org/papers/9a87d84b2ed00ed82a6e297a4c34b3cf) on [The Journal of Open Source Software](https://joss.theoj.org/) website.

### Currently supported platforms

- Configurations for special environments like supercomputers
- Linux with gcc/gfortran, Intel, and Cray compilers
- macOS with gcc/gfortran and Intel compilers
- Windows with MinGW-w64 and gcc/gfortran


### Currently unsupported features

- WRF-DA
- WRFPLUS
- WRF-Chem
- WRF-Hydro
- Promotion of Fortran's REAL to DOUBLE
- File and line number in wrf_error_fatal() messages
- WRF-NMM (discontinued -- see https://dtcenter.org/wrf-nmm/users/)
- Automatic moving nests (via `TERRAIN_AND_LANDUSE` environment variable)


## Installation

The installation of WRF-CMake or WPS-CMake is straightforward thanks to the downloadable pre-built binaries for most Linux distributions (specifically [ RPM-based and Debian-based distribution-compatible](https://en.wikipedia.org/wiki/List_of_Linux_distributions)), macOS, and Windows (see [binary distribution](#binary-distribution-experimental) below) -- most users wishing to run WRF on their system can simply download the pre-compiled binaries without the need of building from source. Alternately, you can install WRF-CMake or WPS-CMake using the Homebrew/Linuxbrew package manager or by building and installing the software from source, please refer to the build and install [manually from source](#manually-from-source) and [Using Homebrew or Linuxbrew](using-homebrew-or-linuxbrew) section below.

Please note that HPC users, or users seeking to run WRF in the 'most optimal' configuration for their system, are advised to build WRF-CMake manually from source or using the Homebrew/Linuxbrew package manager.


### Manually from source
To build and install WRF-CMake or WPS-CMake manually from source, see [this page](doc/cmake/INSTALL.md).

### Using Homebrew or Linuxbrew
WRF-CMake and WPS-CMake can be built and installed using [Homebrew](https://docs.brew.sh/Installation) (macOS) or [Linuxbrew](https://docs.brew.sh/Homebrew-on-Linux#install) (Linux) with the following commands:

``` bash
brew tap wrf-cmake/wrf
# Apple Clang is not supported in latest avalable WRF-CMake release (4.0.3),
# however this has now been fixed and the fixes are available from the wrf-cmake branch.
# We pass the `--HEAD` flag to buld WRF-CMake and WPS-CMake from the latest commit from the wrf-cmake branch.
brew install wrf --HEAD -v
```


### Binary distribution (Experimental)

To download the latest pre-compiled binary releases, see below -- please note that these distributions are currently experimental, therefore please report any issues [here](https://github.com/WRF-CMake/WRF/issues).

- WRF-CMake (`serial` and `dmpar`): [https://github.com/WRF-CMake/WRF/releases](https://github.com/WRF-CMake/WRF/releases).
- WPS-CMake (`serial` and `dmpar`): [https://github.com/WRF-CMake/WPS/releases](https://github.com/WRF-CMake/WPS/releases).


#### Note on MPI

If you want to launch WRF-CMake and WPS-CMake built in `dmpar` to run on multiple processes, you need to have MPI installed on your system.

- On Windows, download and install Microsoft MPI (`msmpisetup.exe`) from [https://github.com/Microsoft/Microsoft-MPI/releases](https://github.com/Microsoft/Microsoft-MPI/releases).
- On macOS you can get it through [Homebrew](https://brew.sh/) using `brew update && brew install mpich`.
- On Linux, use your package manager to download mpich (version ≥ 3.0.4). E.g. `sudo apt-get update && sudo apt-get install mpich` on Debian-based systems or `sudo yum install mpich` on RPM-based system like CentOS.


## Documentation

- For the WRF model technical documentation, please refer to [A Description of the Advanced Research WRF Version 3](https://opensky.ucar.edu/islandora/object/technotes%3A500/datastream/PDF/view).
- For the WRF model user documentation, please refer to [The Advanced Research WRF version 4 Modeling System User’s Guide](http://www2.mmm.ucar.edu/wrf/users/docs/user_guide_v4/contents.html).

## Example usage

If you have already used WRF/WPS before and you just want a quick tutorial to go over the main steps, we have put together a very basic tutorial on our sister-project's website [GIS4WRF](https://gis4wrf.github.io/) with step-by-step instructions [here](https://gis4wrf.github.io/tutorials/wrf-cmake/simulate-the-2018-european-heat-wave-with-wrf-cmake/).

Otherwise, if you are a complete beginner, we recommend going [trough the basics](http://www2.mmm.ucar.edu/wrf/OnLineTutorial/Basics/index.php) or [running the case studies](http://www2.mmm.ucar.edu/wrf/OnLineTutorial/CASES/index.php) as described in the [WRF-ARW Online Tutorial](http://www2.mmm.ucar.edu/wrf/OnLineTutorial/).


## How to cite

When using WRF-CMake in your project or publication, please cite the model as well as the software and version number as shown in the example below. Please make sure that you reference the correct DOI when referencing the software version you are using -- for a list of versions and corresponding DOIs, please see the archived versions on Zenodo at: [TODO]

*We used the WRF (Skamarock et al., 2008) model WRF-CMake (Riechert and Meyer, 2019a), version 4.1 (Riechert and Meyer, 2019b) to [...]*

The corresponding reference list should be as follows

W.C. Skamarock, J.B. Klemp, J. Dudhia, D.O. Gill, D.M. Barker, M.G. Duda, X.-Y. Huang, W. Wang, J.G. Powers
**A Description of the Advanced Research WRF Version 3**. NCAR Tech (2008). Note NCAR/TN-475+STR. https://doi.org/10.5065/D68S4MVH

Riechert and Meyer, 2019a: TODO

Riechert and Meyer, 2019b: TODO


## How to contribute

If you are looking to contribute, please read our [Contributors' guide](CONTRIBUTING.md) for details.


## Testing framework

In our current GitHub set-up, we perform a series of compilation and regression tests at each commit using the [WRF-CMake Automated Testing Suite](https://github.com/WRF-CMake/wats) on Windows, macOS, and Linux. You can find the results of such tests [here](https://travis-ci.com/WRF-CMake), [here](https://ci.appveyor.com/project/WRF-CMake/wrf), and [here](https://ci.appveyor.com/project/WRF-CMake/wps).


## Changes to be upstreamed

The following is a list of changes to be upsteamed:

- `dyn_em/module_big_step_utilities_em.F`: Fix non-standard line continuation character (`\` instead of `&`) leading to compile errors on Cray compilers
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

General WRF copyright and license applies for any files part of the original WRF distribution -- see the [README](README) file for more details.

Additional files provided by WRF-CMake are licensed according to [LICENSE_CMAKE.txt](LICENSE_CMAKE.txt) if the relevant file contains the following header at the beginning of the file, otherwise the general WRF copyright and license applies.
```
WRF-CMake (https://github.com/WRF-CMake/WRF).
Copyright <year> M. Riechert and D. Meyer. Licensed under the MIT License.
```

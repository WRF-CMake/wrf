# Install WRF-/WPS-CMake from source

There are two mandatory and one optional step to install WRF-/WPS-CMake from source on your system:
1. [Install dependencies](#install-dependencies) (required)
2. [Build and Install WRF-CMake](#build-and-install-wrf-cmake) (required)
3. [Build and Install WPS-CMake](#build-and-install-wps-cmake) (optional)

[Homebrew](https://github.com/WRF-CMake/homebrew-wrf) users: You can build and install an MPI-enabled release version with basic nesting support with:
```sh
brew tap wrf-cmake/wrf
brew install wrf-cmake -v
```
For more flexibility, e.g. when changing the registry, see the manual build instructions below.

## Install dependencies
The following libraries are required on your system to install WRF-CMake from source: [Git](https://git-scm.com/), [JasPer](https://www.ece.uvic.ca/~frodo/jasper/), [libpng](http://www.libpng.org/pub/png/libpng.html), [libjpeg](http://libjpeg.sourceforge.net/), [zlib](https://zlib.net/), [HDF5](https://support.hdfgroup.org/HDF5/), [NetCDF-C](https://www.unidata.ucar.edu/downloads/netcdf/index.jsp), [NetCDF-Fortran](https://www.unidata.ucar.edu/downloads/netcdf/index.jsp), and MPI (required if building in `dmpar` or `dm_sm` mode). The above libraries are most likely available from your system's package manager (e.g. APT, yum, Homebrew, etc.). If you do not have the latest version of these libraries installed on your system, please see [this page](LIBS.md).

## Build and Install WRF-CMake

### Transition from original build system

| Original      | CMake          |
| ------------- | -------------- |
| `./configure` | `cmake ...`    |
| `./compile`   | `make install` |

Further notes:
- The original build system uses a series of terminal prompts when running `./configure` whereas for CMake any non-default options need to be specified as command-line arguments.
- If you change any registry files, then just re-run `make install`.

### On Linux and macOS
The general commands to download, configure and install WRF-CMake on Linux and macOS are:

``` sh
git clone https://github.com/WRF-CMake/WRF.git
cd WRF
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=<install_directory> ..
make install
```
where `<install_directory>` is the directory where to install WRF. Depending on your system's configuration, you may need to specify [WRF-CMake options](#wrf-cmake-options). If multiple compilers are available on the system, use the `CC` (C compiler) and/or `FC` (Fortran compiler) environment variables to specify them. For example, to use Intel C and Fortran compilers run `CC=icc FC=ifort cmake -DCMAKE_INSTALL_PREFIX=<install_directory> ..`. On macOS, use `CC=gcc-8 FC=gfortran-8` to use the GNU compilers installed with Homebrew. If your system has enough memory you can enable parallel compilation with `make install -j <n>` where `<n>` is the maximum number of jobs you like to run in parallel.

#### Note for HPC users relying on the Modules package
If you are using `modules` for the dynamic modification of the user's environment via modulefiles, you will need to specify the path to the NetCDF manually _after_ loading all the libraries required to compile WRF/WPS. For example:

``` sh
# This is an example, module names/versions may be different on your system
module list # enabled modules
module avail # available modules
module load cmake
module load netcdf4
module load openmpi
module load gnu/8.1.0
```

If you do not know the location of NetCDF, you can locate it with the `nc-config --prefix`. Then, manually specify the path NetCDF-C and NetCDF-Fortran installation directories at configure time:

``` sh
cmake -DNETCDF_DIR=<path_to_netcdf-c-dir> -DNETCDF_FORTRAN_DIR=<path_to_netcdf-fortran-dir> ..
```

where `<path_to_netcdf-c-dir>` and `<path_to_netcdf-fortran-dir>` are the absolute path to your NetCDF-C and NetCDF-Fortran installation directories.

### On Windows (with MinGW-w64 and gcc/gfortran)
Make sure you [installed all the required dependencies](README_CMAKE_LIBS.md) before continuing.

#### Build WRF-CMake in serial mode
Open an MSYS2 **MinGW 64-bit** shell and run:
```sh
git clone https://github.com/WRF-CMake/WRF.git
cd WRF
mkdir build && cd build
cmake -G "MSYS Makefiles" -DCMAKE_INSTALL_PREFIX=<install_directory> ..
make install
```
The folder `<install_directory>` now contains the WRF installation and is ready to use.
If your system has enough memory you can enable parallel compilation with `make install -j <n>` where `<n>` is the maximum number of jobs you like to run in parallel.

#### Build WRF-CMake with MPI support
Open an MSYS2 **MinGW 64-bit** shell and run:
```sh
git clone https://github.com/WRF-CMake/WRF.git
cd WRF
mkdir build && cd build
cmake -G "MSYS Makefiles" -DMODE=dmpar -DCMAKE_INSTALL_PREFIX=<install_directory> \
    -DMPI_INCLUDE_PATH=$MINGW_PREFIX/include -DMPI_C_LIBRARY="$MSMPI_LIB64/msmpi.lib" \
    -DMPI_Fortran_LIBRARY="$MSMPI_LIB64/msmpifec.lib" ..
make install
```
The folder `<install_directory>` now contains the WRF installation and is ready to use.
If your system has enough memory you can enable parallel compilation with `make install -j <n>` where `<n>` is the maximum number of jobs you like to run in parallel.

### WRF-CMake options
By default WRF-CMake will compile in `serial` mode with `basic` nesting option. You can change this by specifying the option (or flag) at configure time. The general syntax for specifying an option in CMake is `-D<flag_name>=<flag_value>` where `<flag_name>` is the option/flag name and `<flag_value>` is the option/flag value. The following options can be specified when configuring WRF-CMake:

| Name                    | Options                                | Default   | Description                                                 |
| ----------------------- | -------------------------------------- | --------- | ----------------------------------------------------------- |
| `MODE`                  | `serial`, `dmpar`, `smpar`, `dm_sm`    | `serial`  | Serial/parallel modes                                       |
| `NESTING`               | `none`, `basic`, `vortex`, `following` | `basic`   | Domain Options                                              |
| `CMAKE_BUILD_TYPE`      | `Release`, `Debug`, `RelWithDebInfo`   | `Release` | Whether to optimise/build with debug flags.                 |
| `ENABLE_RUNTIME_CHECKS` | `ON`, `OFF`                            | `OFF`     | Whether to enable compiler runtime checks in Release mode.  |
| `ENABLE_GRIB1`          | `ON`, `OFF`                            | `ON`      | Enable/Disable GRIB 1 support.                              |
| `ENABLE_GRIB2`          | `ON`, `OFF`                            | `ON`      | Enable/Disable GRIB 2 support.                              |
| `NETCDF_DIR`            | `<path>`                               | -         | Path to NetCDF-C installation directory (_OPTIONAL_).       |
| `NETCDF_FORTRAN_DIR`    | `<path>`                               | -         | Path to NetCDF-Fortran installation directory (_OPTIONAL_). |


For example, to build and install WRF-CMake on Linux/macOS by setting all the available options and installing in `~/apps/WRF` with gcc and gfortran:
``` sh
# Assumes you are in the WRF directory
CC=gcc FC=gfortran cmake -DCMAKE_INSTALL_PREFIX=~/apps/WRF \
    -DCMAKE_BUILD_TYPE=Release -DMODE=dmpar -DNESTING=basic \
    -DENABLE_GRIB1=ON -DENABLE_GRIB2=ON  ..
make install
```

## Build and Install WPS-CMake

If you intend to run real cases in WRF-CMake, you will also need to compile WPS-CMake. After you installed WRF-CMake, you can download, configure and install WPS-CMake with the following commands:

``` sh
git clone https://github.com/WPS-CMake/WPS.git
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=<install_directory> -DWRF_DIR=<wrf_cmake_build_directory> ..
make install
```

where `<install_directory>` is the directory where to install WPS and `<wrf_cmake_build_directory>` is the path to the `build` folder of WRF (relative or absolute). To specify more options, please see the [WPS-CMake options](#wps-cmake-options).
You can enable parallel compilation with `make install -j <n>` where `<n>` is the maximum number of jobs you like to run in parallel.

### WPS-CMake options

| Name                    | Options                              | Default   | Description                                                 |
| ----------------------- | ------------------------------------ | --------- | ----------------------------------------------------------- |
| `CMAKE_BUILD_TYPE`      | `Release`, `Debug`, `RelWithDebInfo` | `Release` | Whether to optimise/build with debug flags.                 |
| `ENABLE_RUNTIME_CHECKS` | `ON`, `OFF`                          | `OFF`     | Whether to enable compiler runtime checks in Release mode.  |
| `ENABLE_GRIB1`          | `ON`, `OFF`                          | `OFF`     | Enable/Disable GRIB 1 support (`ungrib` always has GRIB 1). |
| `ENABLE_GRIB2_PNG`      | `ON`, `OFF`                          | `ON`      | Enable/Disable GRIB 2 PNG support.                          |
| `ENABLE_GRIB2_JPEG2000` | `ON`, `OFF`                          | `ON`      | Enable/Disable GRIB 2 JPEG2000 support.                     |
| `WRF_DIR`               | `<path>`                             | -         | Path to the `build` folder of WRF.                          |

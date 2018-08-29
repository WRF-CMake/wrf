# How to install required libraries for WRF-CMake
The following libraries are required on your system to install WRF-CMake from source: [Git](https://git-scm.com/), [JasPer](https://www.ece.uvic.ca/~frodo/jasper/), [libpng](http://www.libpng.org/pub/png/libpng.html), [libjpeg](http://libjpeg.sourceforge.net/), [zlib](https://zlib.net/), [HDF5](https://support.hdfgroup.org/HDF5/), [NetCDF-C](https://www.unidata.ucar.edu/downloads/netcdf/index.jsp), [NetCDF-Fortran](https://www.unidata.ucar.edu/downloads/netcdf/index.jsp), and MPI (required if building in `dmpar` or `dm+sm` mode). We assume that you have administrative privileges on your computer.

## Table of contents
- [Ubuntu](#ubuntu)
- [macOS](#macOS)
- [Windows](#windows)
    - [Microsoft MPI](#microsoft-mpi)

## Ubuntu
```sh
sudo apt-get install libjasper-dev libjpeg-dev libpng-dev zlib1g-dev libmpich-dev
```

## macOS
```sh
brew update
brew install gcc netcdf jasper
```

## Windows
- Install the 64bit version of [MSYS2](http://www.msys2.org/)
- If you already have MSYS2 installed, make sure that you didn't compile and install any of WRF's dependencies within the **MSYS** shell, otherwise these might be picked up by accident within the **MinGW** shell. To be sure, use a fresh MSYS2 install.
- Inside the MSYS2 **MinGW 64-bit** shell, run `pacman -Syu`
- Restart the shell
- Run `pacman -Syu` again to finish upgrading
- Run `pacman -S --noconfirm --needed make unzip git mingw-w64-x86_64-toolchain mingw64/mingw-w64-x86_64-cmake mingw64/mingw-w64-x86_64-portablexdr`
- Run `pacman -S --noconfirm --needed mingw-w64-x86_64-libpng mingw-w64-x86_64-libjpeg-turbo mingw-w64-x86_64-jasper` (for WPS; or WRF with GRIB 2 support)
- Run `pacman -S --noconfirm --needed mingw-w64-x86_64-hdf5 mingw-w64-x86_64-libtool tar` (only needed for temporary netCDF compilation below)

Temporary netCDF installation instructions (until https://github.com/Unidata/netcdf-c/issues/554 and https://github.com/Unidata/netcdf-c/issues/1105 are resolved and the MinGW-w64 package is updated):
```sh
cd ~
git clone https://github.com/WRF-CMake/netcdf-c.git -b letmaik/mingw
cd netcdf-c
mkdir build && cd build
cmake -DCMAKE_GENERATOR="MSYS Makefiles" -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DENABLE_TESTS=OFF -DENABLE_DAP=FALSE -DNC_FIND_SHARED_LIBS=OFF -DBUILD_UTILITIES=OFF -DENABLE_EXAMPLES=OFF -DCMAKE_INSTALL_PREFIX=$MINGW_PREFIX ..
make install
rm -rf $MINGW_PREFIX/lib/cmake/netCDF # breaks for some reason otherwise in netcdf-fortran
rm -rf * # avoid cmake cache using this directly in netcdf-fortran
cd ~
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.4.4.tar.gz
tar xvzf netcdf-fortran-4.4.4.tar.gz
cd netcdf-fortran-4.4.4
sed -i 's/ADD_SUBDIRECTORY(examples)/#ADD_SUBDIRECTORY(examples)/' CMakeLists.txt
mkdir build && cd build
cmake -DCMAKE_GENERATOR="MSYS Makefiles" -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DENABLE_TESTS=OFF -DCMAKE_INSTALL_PREFIX=$MINGW_PREFIX ..
make install
```

### Microsoft MPI
The following MS MPI instructions originated from:
- http://www.math.ucla.edu/~wotaoyin/windows_coding.html
- https://github.com/coderefinery/autocmake/issues/85

Download and install both `msi` and `exe` from https://www.microsoft.com/en-us/download/details.aspx?id=56727.

Restart the MSYS2 **MinGW 64-bit** shell and run:
```sh
mkdir ~/msmpi && cd ~/msmpi
cp "$MSMPI_INC/mpi.h" .
sed -i '1s/^/#include <stdint.h>\n/' mpi.h
cp mpi.h $MINGW_PREFIX/include
cpp -P -nostdinc -traditional-cpp -DINT_PTR_KIND\(\)=8 "$MSMPI_INC/mpif.h" > $MINGW_PREFIX/include/mpif.h
cp "$MSMPI_INC/mpi.f90" mpi.F90
cp "$MSMPI_INC/x64/mpifptr.h" $MINGW_PREFIX/include
gfortran -c -fno-range-check -I$MINGW_PREFIX/include -DINT_PTR_KIND\(\)=8 mpi.F90
cp mpi.mod $MINGW_PREFIX/include
cd ~
```

Technical note: Preprocessing `mpif.h` is required as WRF `include`s this file instead of `#include` and then no preprocessing would take place.

The `~/msmpi` folder is not needed anymore and can now be removed.
```sh
rm -rf ~/msmpi
```

To verify that MPI is working correctly, run:
```sh
cd ~
mkdir mpi_test && cd mpi_test
# can run with and without MPI
wget https://raw.githubusercontent.com/wesleykendall/mpitutorial/gh-pages/tutorials/mpi-hello-world/code/mpi_hello_world.c
# checks if MPI launches 2 processes
wget https://raw.githubusercontent.com/coderefinery/autocmake/c5057f8aee65/test/fc_mpi/src/example.F90
gcc mpi_hello_world.c -D_WIN64 -lmsmpi -L"$MSMPI_LIB64" -o mpi_hello
gfortran -o example1 example.F90 -fno-range-check -lmsmpifec -lmsmpi -L"$MSMPI_LIB64" -I$MINGW_PREFIX/include
gfortran -o example2 -DUSE_MPI_MODULE example.F90 -fno-range-check -lmsmpifec -lmsmpi -L"$MSMPI_LIB64" -I$MINGW_PREFIX/include
./mpi_hello # 1 process
export PATH="$MSMPI_BIN":$PATH
mpiexec -n 4 mpi_hello.exe
mpiexec -n 2 example1.exe
mpiexec -n 2 example2.exe
```

If everything went OK, you can now build WRF with MPI.
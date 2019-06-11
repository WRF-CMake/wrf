@echo off

rem WRF-CMake (https://github.com/WRF-CMake/WRF).
rem Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

rem Adapted from https://github.com/meta-toolkit/meta/blob/c7019401185cdfa15e1193aad821894c35a83e3f/.appveyor.yml

set THIS_FOLDER=%~dp0

set HTTP_RETRIES=3

if "%MODE:~0,2%"=="dm" (
    echo Install MSMPI
    rem v10 currently unusable (https://github.com/Microsoft/Microsoft-MPI/issues/7)
    rem pwsh -c Invoke-WebRequest -MaximumRetryCount %HTTP_RETRIES% -OutFile msmpisetup.exe https://github.com/Microsoft/Microsoft-MPI/releases/download/v10.0/msmpisetup.exe || goto :error
    rem pwsh -c Invoke-WebRequest -MaximumRetryCount %HTTP_RETRIES% -OutFile msmpisdk.msi https://github.com/Microsoft/Microsoft-MPI/releases/download/v10.0/msmpisdk.msi || goto :error
    rem v9.0.1
    pwsh -c Invoke-WebRequest -MaximumRetryCount %HTTP_RETRIES% -OutFile msmpisetup.exe https://download.microsoft.com/download/4/A/6/4A6AAED8-200C-457C-AB86-37505DE4C90D/msmpisetup.exe || goto :error
    pwsh -c Invoke-WebRequest -MaximumRetryCount %HTTP_RETRIES% -OutFile msmpisdk.msi https://download.microsoft.com/download/4/A/6/4A6AAED8-200C-457C-AB86-37505DE4C90D/msmpisdk.msi || goto :error
    msmpisetup.exe -unattend || goto :error
    msmpisdk.msi /passive || goto :error
)

rem Remember original PATH as refreshenv will replace it with the state from the system registry
set OLDPATH=%PATH%

rem MSMPI addds global vars like MSMPI_INC -- need to propagate these changes to current shell.
rem Use Chocolatey cmd (https://stackoverflow.com/a/44807922).
rem Note: This overrides PATH, hence PATH is updated after this.
call refreshenv.cmd

rem Restore old PATH after refreshenv in case other scripts modified it already
set PATH=%OLDPATH%

echo Install MSYS2
choco install msys2 --params "/InstallDir:c:\wrf_msys64 /NoUpdate"

rem Setup MinGW shell
set PATH=C:\wrf_msys64\usr\bin;%PATH%
set MSYSTEM=MINGW64

echo Install MinGW64 Packages
bash -lc "pacman --noconfirm -Syu" || goto :error
bash -lc "pacman --noconfirm -Su" || goto :error
bash -lc "pacman --noconfirm --needed -S mingw-w64-x86_64-gcc mingw-w64-x86_64-gcc-fortran mingw-w64-x86_64-cmake make unzip git mingw-w64-x86_64-portablexdr" || goto :error
bash -lc "pacman --noconfirm --needed -S mingw-w64-x86_64-libpng mingw-w64-x86_64-libjpeg-turbo mingw-w64-x86_64-jasper" || goto :error
bash -lc "pacman --noconfirm --needed -S mingw-w64-x86_64-hdf5 mingw-w64-x86_64-libtool tar" || goto :error

if "%MODE:~0,2%"=="dm" (
    echo Patch MSMPI
    bash -l "%THIS_FOLDER%patch-msmpi-v9.sh" || goto :error
    echo Test MSMPI
    bash -l "%THIS_FOLDER%test-msmpi.sh" || goto :error
)
echo Install NetCDF
bash -l "%THIS_FOLDER%install-netcdf.sh" || goto :error

goto :EOF

:error
exit /b %errorlevel%
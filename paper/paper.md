---
title: 'WRF-CMake: integrating CMake support into the Advanced Research WRF (ARW) modelling system'
tags:
  - cmake
  - fortran
  - meteorology
  - weather
  - modelling
  - nwp
  - wrf
authors:
  - name: M. Riechert
    orcid: 0000-0003-3299-1382
    affiliation: 1
  - name: D. Meyer
    orcid: 0000-0002-7071-7547
    affiliation: 1
affiliations:
  - name: Independent scholar
    index: 1
date: 14 May 2019
bibliography: paper.bib
---


# Summary

The Weather Research and Forecasting model (WRF[^1]) model [@Skamarock2019] is an atmospheric modelling system widely used in operational forecasting and atmospheric research [@Powers2017]. WRF is released as a free and open-source software and officially supported to run on Unix and Unix-like operating systems and on different hardware architectures from single-core computers to multi-core supercomputers. Its current build system relies on several bespoke hand-written Makefiles, and Perl and Shell scripts that have been supported and extended during the many years of development.

The use of build script generation tools, that is, tools that generate files for native build systems from specifications in a high-level language, rather than manually maintaining build scripts for different environments and platforms, can be useful to reduce code duplication and to minimize issues with code not building correctly [@Hoffman2009], to make software more accessible to a broader audience, and the support less expensive [@Heroux2009]. As such, a common build script generation tool is [CMake](https://cmake.org/). Today, CMake is employed in several projects such as [HDF5](https://www.hdfgroup.org/), [EnergyPlus](https://energyplus.net/), and [ParaView](https://www.paraview.org/) to build modern software written in C, C++, and Fortran in high performance computing (HPC) environments and, by CERN, to allow users to easily set-up and build several million lines of C++ and Python code used in the offline software of the ATLAS experiment at the Large Hadron Collider (LHC) [@Elmsheuser2017].

[WRF-CMake](https://github.com/WRF-CMake/WRF) aims at helping model developers and end-users by adding CMake support to the latest version of WRF and the WRF Processing System (WPS), while coexisting with the existing build set-up. The main goals of WRF-CMake are to simplify the build process involved in developing and building WRF and WPS, add support for automated testing using continuous integration (CI), and the generation of pre-built binary releases for Linux, macOS, and Windows thus allowing non-expert users to get started with their simulations in a few minutes, or integrating WRF and WPS into other software (see, for example, the [GIS4WRF](https://github.com/GIS4WRF/gis4wrf) project [@Meyer2019]).
The WRF-CMake project provides model developers, code maintainers, and end-users wishing to build WRF and WPS on their system several advantages such as robust incremental rebuilds, dependency analysis of Fortran code, flexible library dependency discovery, automatic construction of compiler command-lines based on the detected compiler, and integrated support for MPI and OpenMP. Furthermore, by using a single language to control the build, CMake removes the need to write and support several hand-written Makefiles, and Perl and Shell scripts. The current WRF-CMake set-up on GitHub offers model developers and code maintainers an automated testing infrastructure (see [Testing](#testing)) for Linux, macOS, and Windows, and allows end-users to directly download pre-built binaries for common configurations and architectures from the project’s website.
WRF-CMake is available as a free and open-source project on GitHub at [https://github.com/WRF-CMake](https://github.com/WRF-CMake) and currently includes CMake support for the main [Advanced Research WRF (ARW) core](https://github.com/WRF-CMake/WRF) and [WPS](https://github.com/WRF-CMake/WPS). Support for WRF-DA, WRFPLUS, WRF-Chem, and WRF-Hydro, may be included in future versions of WRF-CMake depending on the feedback and general uptake by the community.


# Testing

A fundamental aspect of software development is testing. Ideally, model components should be tested individually and under several testing methodologies [@Feathers2004]. As the WRF framework does not offer a way to unit test its components, we instead run build and integration tests to evaluate the effects of our changes.

Build and integration tests are performed for all supported configurations (Table 1) using continuous integration services. Build tests are run at every code commit. Integration tests are run using the [WRF-CMake Automated Testing Suite (WATS)](https://github.com/WRF-CMake/wats) with a subset of namelists from the official [WRF Testing Framework](https://github.com/wrf-model/WTF) only at major code changes (e.g. before merging pull requests) to constrain computing resources.

| Dimension  | Variant                             |
| ---------- | ----------------------------------- |
| OS         | `Linux`, `macOS`, `Windows`         |
| Build tool | `Make`, `CMake`                     |
| Build type | `Debug`, `Release`                  |
| Mode       | `serial`, `dmpar`, `smpar`, `dm_sm` |


Table: Configurations used for build and integration tests. `Make`: original WRF build system files; `CMake`: this paper; `Debug`: compiler-optimizations disabled; `Release`: compiler-optimizations enabled; `serial`: single processor support; `dmpar`: multiple processor (MP) with distributed memory support (MPI), `smpar` with shared memory support (OpenMP), and `dm_sm` MP with distributed and shared memory support (MPI and OpenMP).

As noted by Hodyss and Majumdar [-@Hodyss2007], and Geer [-@Geer2016], the high sensitivity to initial conditions of dynamical systems, such as the ones used in weather models, can lead to large differences in skill between any two forecasts. It is this high sensitivity to the initial conditions that can obscure the source of model error, whether this originates from a change in compiler or architecture, an actual coding error, or indeed, the intrinsic nature of the dynamical system employed. As a result, we evaluate the impact of our changes by comparing the outputs from integration tests against a reference build defined as `Linux/Make/Debug/serial` using [relative percentage error](https://en.wikipedia.org/w/index.php?title=Approximation_error&oldid=878331002#Formal_Definition) ($\delta$) and [normalised root mean square error](https://en.wikipedia.org/w/index.php?title=Root-mean-square_deviation&oldid=893196204#Normalized_root-mean-square_deviation) (NRMSE) at the start of the simulation (Figure 1, A0 and B0) and after 60 minutes (Figure 1, A60 and B60). Both $\delta$ and NRMSE are computed per domain for all grid-points on all vertical levels. Normalizing factors are computed per grid-point for $\delta$ and per domain, per quantity, per variant, on all vertical-levels and grid-points for NRMSE. $\boldsymbol{\delta}$ represents the vector of all $\delta$s per domain.


| Symbol   | Name                                  | Unit                   |
| -------- | ------------------------------------- | ---------------------- |
| $p$      | Air pressure                          | $\mathsf{Pa}$          |
| $\phi$   | Surface geopotential                  | $\mathsf{m^2\ s^{-2}}$ |
| $\theta$ | Air potential temperature             | $\mathsf{K}$           |
| $u$      | Zonal component of wind velocity      | $\mathsf{m\ s^{-1}}$   |
| $v$      | Meridional component of wind velocity | $\mathsf{m\ s^{-1}}$   |
| $w$      | Vertical component of wind velocity   | $\mathsf{m\ s^{-1}}$   |

Table: WRF prognostic variables evaluated during integration tests.


Results from the evaluation show that the choice of operating system has the greatest impact on both $\delta$ and NRMSE (Figure 1) over compiler optimization strategies and build tool used. A change in build tool to CMake appears to produce values of $\delta$ and NRMSE consistent with to those obtained from versions of WRF built with the original build scripts[^2]. High values in NRMSE for $w$ are caused by small absolute values of $w$ (i.e. small absolute errors yield high NRMSE values). The choice of operating system, particularly when considering `Debug` configurations, appear to be a general property of WRF (i.e. with/without CMake support) and should be investigated further.


![`A`: extended box plots of relative percentage errors ($\boldsymbol{\delta}$) against the reference configuration (`Linux/Make/Debug/serial`) for the domain with highest errors only (domain 2). `B`: normalised root mean-square error (NRMSE). 0 and 60 show the number of minutes elapsed since the start of the simulation. Extended boxplots show minimum, maximum, median, and percentiles at [99.9, 99, 75, 25, 5, 1, 0.1].](wrf-cmake-stats-plots.pdf)


# Concluding remarks

We introduce WRF-CMake as a modern replacement for the existing WRF build system. Its main goals are to simplify the build process involved in developing and building WRF and WPS, add support for automated testing using CI, and automate the generation of pre-built binary releases for Linux, macOS, and Windows. Results from the limited integration tests indicate that values of $\delta$ and NRMSE from outputs of prognostic variables produced using WRF-CMake are consistent with those produced using the original build system. Future work may add support for WRF-DA, WRFPLUS, WRF-Chem, and WRF-Hydro, depending on feedback and general uptake by the community.


# Acknowledgements

We thank A. J. Geer at the European Centre for Medium-Range Weather Forecasts (ECMWF) for the useful discussion and feedback concerning the topic of error growth in dynamical systems.


# References


[^1]: By WRF, we specifically mean the Advanced Research WRF (ARW). The Non-hydrostatic Mesoscale Model (NMM) dynamical core, WRF-DA, WRFPLUS, WRF-Chem, and WRF-Hydro are not currently supported in WRF-CMake.

[^2]: Comparison on Windows was not made as Windows support is only available in WRF-CMake.
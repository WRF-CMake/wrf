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

The Weather Research and Forecasting model (WRF[^1]) model [@Skamarock2019] is an atmospheric modelling system widely used in operational forecasting and atmospheric research [@Powers2017]. WRF is released as a free and open-source software and officially supported to run on Unix and Unix-like operating systems and on several hardware architectures from single-core computers to multi-core supercomputers. Its current build system relies on several bespoke hand-written Makefiles, and Perl and Shell scripts that have been supported and extended during the many years of development.

The use of build script generation tools, that is, tools that generate files for native build systems from specifications in a high-level language, rather than manually maintaining build scripts for different environments and platforms, can be useful to reduce code duplication and to minimize issues with code not building correctly [@Hoffman2009], to make software more accessible to a broader audience, and the support less expensive [@Heroux2009]. As such, a common build script generation tool is [CMake](https://cmake.org/). Today, CMake is employed in several projects such as [HDF5](https://www.hdfgroup.org/), [EnergyPlus](https://energyplus.net/), and [ParaView](https://www.paraview.org/) to build modern software written in C, C++, and Fortran in high performance computing (HPC) environments and, by CERN, to allow users to easily set-up and build several million lines of C++ and Python code used in the offline software of the ATLAS experiment at the Large Hadron Collider (LHC) [@Elmsheuser2017].

[WRF-CMake](https://github.com/WRF-CMake/WRF) aims at helping model developers and end-users by adding CMake support to the latest version of WRF and the WRF Processing System (WPS), while coexisting with the existing build set-up. The main goals of WRF-CMake are to simplify the build process involved in developing and building WRF and WPS, add support for automated testing using continuous integration (CI), and the generation of pre-built binary releases for Linux, macOS, and Windows thus allowing non-expert users to get started with their simulations in a few minutes, or integrating WRF and WPS into other software (see, for example, the [GIS4WRF](https://github.com/GIS4WRF/gis4wrf) project [@Meyer2019]).
The WRF-CMake project provides model developers, code maintainers, and end-users wishing to build WRF and WPS on their system several advantages such as robust incremental rebuilds, dependency analysis of Fortran code, flexible library dependency discovery, automatic construction of compiler command-lines based on the detected compiler, and integrated support for MPI and OpenMP. Furthermore, by using a single language to control the build, CMake removes the need to write and support several hand-written Makefiles, and Perl and Shell scripts. The current WRF-CMake set-up on GitHub offers model developers and code maintainers an automated testing infrastructure (see [Testing](#testing)) for Linux, macOS, and Windows, and allows end-users to directly download pre-built binaries for common configurations and architectures from the project’s website.
WRF-CMake is available as a free and open-source project on GitHub at [https://github.com/WRF-CMake](https://github.com/WRF-CMake) and currently includes CMake support for the main [Advanced Research WRF (ARW) core](https://github.com/WRF-CMake/WRF) and [WPS](https://github.com/WRF-CMake/WPS).


# Testing

A fundamental aspect of software development is testing. Ideally, model components should be tested individually and under several testing methodologies [@Feathers2004]. As the WRF framework does not offer a way to unit test its components, we instead run build and integration tests to evaluate the effects of our changes.

Build and integration tests are performed for all supported configurations (Table 1) using CI services. Build tests are run at every code commit. Integration tests are run using the [WRF-CMake Automated Testing Suite (WATS)](https://github.com/WRF-CMake/wats) with a subset of namelists from the official [WRF Testing Framework](https://github.com/wrf-model/WTF) only at major code changes (e.g. before merging pull requests) to constrain computing resources.

| Dimension  | Variant                             |
| ---------- | ----------------------------------- |
| OS         | `Linux`, `macOS`, `Windows`         |
| Build tool | `Make`, `CMake`                     |
| Build type | `Debug`, `Release`                  |
| Mode       | `serial`, `dmpar`, `smpar`, `dm_sm` |


Table: Configurations used for build and integration tests. `Make`: original WRF build system files, `CMake`: this paper; `Debug`: compiler optimizations disabled, `Release` enabled; `serial`: single processor, `dmpar`: multiple with distributed memory (MPI), `smpar`: multiple with shared memory (OpenMP), `dm_sm`: multiple with MPI and OpenMP.

As noted by Hodyss and Majumdar [-@Hodyss2007], and Geer [-@Geer2016], the high sensitivity to initial conditions of dynamical systems, such as the ones used in weather models, can lead to large differences in skill between any two forecasts. It is this high sensitivity to initial conditions that can obscure the source of model error, whether this originates from a change in compiler or architecture, an actual coding error, or indeed, the intrinsic nature of the dynamical system employed. As a result, we evaluate the impact of our changes by comparing the outputs from integration tests against a reference configuration defined as `Linux/Make/Debug/serial` using [relative percentage error](https://en.wikipedia.org/w/index.php?title=Approximation_error&oldid=878331002#Formal_Definition) ($\delta$) and [normalised root mean square error](https://en.wikipedia.org/w/index.php?title=Root-mean-square_deviation&oldid=893196204#Normalized_root-mean-square_deviation) (NRMSE) at the start of the simulation (Figure 1, A0 and B0) and after 60 minutes (Figure 1, A60 and B60). Both $\delta$ and NRMSE are computed per domain for all grid points on all vertical levels. Normalizing factors are computed per grid point for $\delta$ and per domain, per quantity, per variant, on all vertical levels and grid points for NRMSE. $\boldsymbol{\delta}$ represents the vector of all $\delta$s per domain.


| Symbol   | Name                                  | Unit                   |
| -------- | ------------------------------------- | ---------------------- |
| $p$      | Air pressure                          | $\mathsf{Pa}$          |
| $\phi$   | Surface geopotential                  | $\mathsf{m^2\ s^{-2}}$ |
| $\theta$ | Air potential temperature             | $\mathsf{K}$           |
| $u$      | Zonal component of wind velocity      | $\mathsf{m\ s^{-1}}$   |
| $v$      | Meridional component of wind velocity | $\mathsf{m\ s^{-1}}$   |
| $w$      | Vertical component of wind velocity   | $\mathsf{m\ s^{-1}}$   |

Table: WRF prognostic variables evaluated during integration tests.


\begin{tiny}
\begin{longtable}{llrrrrrr}
\caption{Make vs CMake Domain 2, 60 min}\\
\toprule
                          &     &  $p$ in $\mathsf{Pa}$ &  $\phi$ in $\mathsf{m^2\ s^{-2}}$ &  $\theta$ in $\mathsf{K}$ &  $u$ in $\mathsf{m\ s^{-1}}$ &  $v$ in $\mathsf{m\ s^{-1}}$ &  $w$ in $\mathsf{m\ s^{-1}}$ \\
Configuration & Statistic &                       &                                   &                           &                              &                              &                              \\
\midrule
\endhead
\midrule
\multicolumn{8}{r}{{Continued on next page}} \\
\midrule
\endfoot

\bottomrule
\endlastfoot
Linux/Debug/dmpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/Debug/dm\_sm & Mean &               5.0e-04 &                           1.6e-02 &                   1.9e-04 &                      3.3e-04 &                      2.8e-04 &                      9.4e-05 \\
                    & SD &               3.6e-03 &                           9.4e-02 &                   2.5e-03 &                      4.9e-03 &                      3.3e-03 &                      7.7e-04 \\
                    & Max &               1.2e+00 &                           9.1e+00 &                   4.7e-01 &                      1.1e+00 &                      7.6e-01 &                      1.3e-01 \\
Linux/Debug/serial & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/Debug/smpar & Mean &               2.9e-04 &                           1.3e-02 &                   1.4e-04 &                      1.8e-04 &                      1.7e-04 &                      7.6e-05 \\
                    & SD &               2.8e-03 &                           1.0e-01 &                   1.7e-03 &                      1.6e-03 &                      1.5e-03 &                      8.1e-04 \\
                    & Max &               1.2e+00 &                           1.2e+01 &                   4.7e-01 &                      2.6e-01 &                      2.5e-01 &                      1.7e-01 \\
Linux/Release/dmpar & Mean &               3.0e-04 &                           1.3e-02 &                   1.3e-04 &                      1.6e-04 &                      1.6e-04 &                      8.0e-05 \\
                    & SD &               3.0e-03 &                           1.1e-01 &                   1.8e-03 &                      1.4e-03 &                      1.4e-03 &                      8.3e-04 \\
                    & Max &               1.2e+00 &                           1.1e+01 &                   4.6e-01 &                      2.1e-01 &                      2.6e-01 &                      1.3e-01 \\
Linux/Release/dm\_sm & Mean &               5.1e-04 &                           1.8e-02 &                   2.0e-04 &                      3.4e-04 &                      3.0e-04 &                      1.0e-04 \\
                    & SD &               3.6e-03 &                           1.1e-01 &                   2.5e-03 &                      4.7e-03 &                      3.5e-03 &                      8.4e-04 \\
                    & Max &               1.2e+00 &                           1.1e+01 &                   5.1e-01 &                      1.1e+00 &                      7.1e-01 &                      1.3e-01 \\
Linux/Release/serial & Mean &               3.0e-04 &                           1.3e-02 &                   1.3e-04 &                      1.6e-04 &                      1.6e-04 &                      8.0e-05 \\
                    & SD &               3.0e-03 &                           1.1e-01 &                   1.8e-03 &                      1.4e-03 &                      1.4e-03 &                      8.3e-04 \\
                    & Max &               1.2e+00 &                           1.1e+01 &                   4.6e-01 &                      2.1e-01 &                      2.6e-01 &                      1.3e-01 \\
Linux/Release/smpar & Mean &               3.0e-04 &                           1.3e-02 &                   1.3e-04 &                      1.6e-04 &                      1.6e-04 &                      8.0e-05 \\
                    & SD &               3.0e-03 &                           1.1e-01 &                   1.8e-03 &                      1.4e-03 &                      1.4e-03 &                      8.3e-04 \\
                    & Max &               1.2e+00 &                           1.1e+01 &                   4.6e-01 &                      2.1e-01 &                      2.6e-01 &                      1.3e-01 \\
macOS/Debug/dmpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
macOS/Debug/dm\_sm & Mean &               5.0e-04 &                           1.7e-02 &                   2.1e-04 &                      3.6e-04 &                      3.1e-04 &                      1.0e-04 \\
                    & SD &               3.5e-03 &                           9.4e-02 &                   2.5e-03 &                      5.0e-03 &                      3.7e-03 &                      7.9e-04 \\
                    & Max &               1.2e+00 &                           8.4e+00 &                   4.7e-01 &                      1.1e+00 &                      9.1e-01 &                      1.3e-01 \\
macOS/Debug/serial & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
macOS/Debug/smpar & Mean &               3.0e-04 &                           1.3e-02 &                   1.4e-04 &                      1.8e-04 &                      1.7e-04 &                      8.0e-05 \\
                    & SD &               2.8e-03 &                           1.0e-01 &                   1.6e-03 &                      1.5e-03 &                      1.5e-03 &                      8.1e-04 \\
                    & Max &               1.3e+00 &                           1.0e+01 &                   4.6e-01 &                      2.2e-01 &                      3.3e-01 &                      1.7e-01 \\
macOS/Release/dmpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
macOS/Release/dm\_sm & Mean &               2.2e-04 &                           4.6e-03 &                   7.4e-05 &                      1.9e-04 &                      1.6e-04 &                      2.6e-05 \\
                    & SD &               2.1e-03 &                           2.6e-02 &                   2.1e-03 &                      5.1e-03 &                      3.8e-03 &                      1.5e-04 \\
                    & Max &               5.8e-01 &                           2.1e+00 &                   4.3e-01 &                      9.2e-01 &                      7.9e-01 &                      1.9e-02 \\
macOS/Release/serial & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
macOS/Release/smpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                    & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
\end{longtable}
\end{tiny}



Results from the evaluation show that the choice of operating system has the greatest impact on both $\delta$ and NRMSE (Figure 1) over compiler optimization strategies and build tool used. A change in build tool to CMake appears to produce values of $\delta$ and NRMSE consistent with those obtained from versions of WRF built with the original build scripts[^2]. High values of NRMSE for $w$ are caused by small absolute values of $w$ (i.e. small absolute errors yield high NRMSE values). Large values of $\delta$ and NRMSE between operating systems, particularly when considering `Debug` configurations, appear to be a general property of WRF (i.e. with/without CMake support) and should be investigated further.


# Concluding remarks

We introduce WRF-CMake as a modern replacement for the existing WRF build system. Its main goals are to simplify the build process involved in developing and building WRF and WPS, add support for automated testing using CI, and automate the generation of pre-built binary releases for Linux, macOS, and Windows. Results from the integration tests indicate that values of $\delta$ and NRMSE from outputs of prognostic variables produced using WRF-CMake are consistent with those produced using the original build system. Future work may involve adding support for WRF-DA, WRFPLUS, WRF-Chem, and WRF-Hydro, depending on feedback and general uptake by the community.


# Acknowledgements

We thank A. J. Geer at the European Centre for Medium-Range Weather Forecasts (ECMWF) for the useful discussion and feedback concerning the topic of error growth in dynamical systems.

# Appendix

\begin{tiny}
\begin{longtable}{llrrrrrr}
\caption{Single ref, t 0min}\\
\toprule
                            &     &  $p$ in $\mathsf{Pa}$ &  $\phi$ in $\mathsf{m^2\ s^{-2}}$ &  $\theta$ in $\mathsf{K}$ &  $u$ in $\mathsf{m\ s^{-1}}$ &  $v$ in $\mathsf{m\ s^{-1}}$ &  $w$ in $\mathsf{m\ s^{-1}}$ \\
Configuration & Statistic &                       &                                   &                           &                              &                              &                              \\
\midrule
\endhead
\midrule
\multicolumn{8}{r}{{Continued on next page}} \\
\midrule
\endfoot

\bottomrule
\endlastfoot
Linux/CMake/Debug/dmpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/CMake/Debug/dm\_sm & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/CMake/Debug/serial & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/CMake/Debug/smpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/CMake/Release/dmpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/CMake/Release/dm\_sm & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/CMake/Release/serial & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/CMake/Release/smpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/Make/Debug/dmpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/Make/Debug/dm\_sm & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/Make/Debug/smpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/Make/Release/dmpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/Make/Release/dm\_sm & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/Make/Release/serial & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/Make/Release/smpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
macOS/CMake/Debug/dmpar & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/CMake/Debug/dm\_sm & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/CMake/Debug/serial & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/CMake/Debug/smpar & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/CMake/Release/dmpar & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/CMake/Release/dm\_sm & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/CMake/Release/serial & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/CMake/Release/smpar & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/Make/Debug/dmpar & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/Make/Debug/dm\_sm & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/Make/Debug/serial & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/Make/Debug/smpar & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/Make/Release/dmpar & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/Make/Release/dm\_sm & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/Make/Release/serial & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
macOS/Make/Release/smpar & Mean &               4.9e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               2.0e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               2.4e-02 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
Windows/CMake/Debug/dmpar & Mean &               4.8e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               1.9e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               7.4e-03 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
Windows/CMake/Debug/dm\_sm & Mean &               4.8e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               1.9e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               7.4e-03 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
Windows/CMake/Debug/serial & Mean &               4.8e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               1.9e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               7.4e-03 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
Windows/CMake/Debug/smpar & Mean &               4.8e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               1.9e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               7.4e-03 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
Windows/CMake/Release/dmpar & Mean &               4.8e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               1.9e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               7.4e-03 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
Windows/CMake/Release/dm\_sm & Mean &               4.8e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               1.9e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               7.4e-03 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
Windows/CMake/Release/serial & Mean &               4.8e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               1.9e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               7.4e-03 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
Windows/CMake/Release/smpar & Mean &               4.8e-05 &                           1.8e-03 &                   2.7e-06 &                      7.4e-07 &                      6.9e-07 &                      1.3e-08 \\
                            & SD &               1.9e-04 &                           5.4e-03 &                   1.0e-05 &                      6.3e-06 &                      6.2e-06 &                      9.5e-08 \\
                            & Max &               7.4e-03 &                           6.2e-02 &                   2.7e-04 &                      3.9e-04 &                      5.1e-04 &                      4.7e-06 \\
\end{longtable}
\end{tiny}




\begin{tiny}
\begin{longtable}{llrrrrrr}
\caption{Single Ref, Domain 2, 60 min}\\
\toprule
                            &     &  $p$ in $\mathsf{Pa}$ &  $\phi$ in $\mathsf{m^2\ s^{-2}}$ &  $\theta$ in $\mathsf{K}$ &  $u$ in $\mathsf{m\ s^{-1}}$ &  $v$ in $\mathsf{m\ s^{-1}}$ &  $w$ in $\mathsf{m\ s^{-1}}$ \\
Configuration & Statistic &                       &                                   &                           &                              &                              &                              \\
\midrule
\endhead
\midrule
\multicolumn{8}{r}{{Continued on next page}} \\
\midrule
\endfoot

\bottomrule
\endlastfoot
Linux/CMake/Debug/dmpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/CMake/Debug/dm\_sm & Mean &               2.8e-04 &                           1.1e-02 &                   1.2e-04 &                      1.4e-04 &                      1.4e-04 &                      7.0e-05 \\
                            & SD &               2.6e-03 &                           8.9e-02 &                   1.6e-03 &                      1.4e-03 &                      1.3e-03 &                      7.6e-04 \\
                            & Max &               1.2e+00 &                           9.7e+00 &                   4.6e-01 &                      2.1e-01 &                      2.1e-01 &                      1.7e-01 \\
Linux/CMake/Debug/serial & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/CMake/Debug/smpar & Mean &               2.7e-04 &                           1.1e-02 &                   1.3e-04 &                      1.6e-04 &                      1.6e-04 &                      6.7e-05 \\
                            & SD &               2.6e-03 &                           8.3e-02 &                   1.7e-03 &                      1.4e-03 &                      1.5e-03 &                      7.2e-04 \\
                            & Max &               8.6e-01 &                           8.3e+00 &                   4.3e-01 &                      2.1e-01 &                      4.9e-01 &                      1.7e-01 \\
Linux/CMake/Release/dmpar & Mean &               1.8e-03 &                           1.0e-01 &                   8.1e-04 &                      2.3e-03 &                      2.7e-03 &                      4.7e-04 \\
                            & SD &               5.7e-03 &                           4.8e-01 &                   7.2e-03 &                      2.1e-02 &                      3.5e-02 &                      2.6e-03 \\
                            & Max &               1.2e+00 &                           3.0e+01 &                   1.1e+00 &                      5.6e+00 &                      1.0e+01 &                      2.3e-01 \\
Linux/CMake/Release/dm\_sm & Mean &               1.8e-03 &                           1.1e-01 &                   8.1e-04 &                      2.3e-03 &                      2.7e-03 &                      4.7e-04 \\
                            & SD &               5.7e-03 &                           4.8e-01 &                   7.2e-03 &                      2.1e-02 &                      3.5e-02 &                      2.6e-03 \\
                            & Max &               1.2e+00 &                           3.0e+01 &                   1.1e+00 &                      5.6e+00 &                      1.0e+01 &                      2.3e-01 \\
Linux/CMake/Release/serial & Mean &               1.8e-03 &                           1.0e-01 &                   8.1e-04 &                      2.3e-03 &                      2.7e-03 &                      4.7e-04 \\
                            & SD &               5.7e-03 &                           4.8e-01 &                   7.2e-03 &                      2.1e-02 &                      3.5e-02 &                      2.6e-03 \\
                            & Max &               1.2e+00 &                           3.0e+01 &                   1.1e+00 &                      5.6e+00 &                      1.0e+01 &                      2.3e-01 \\
Linux/CMake/Release/smpar & Mean &               1.8e-03 &                           1.0e-01 &                   8.1e-04 &                      2.3e-03 &                      2.7e-03 &                      4.7e-04 \\
                            & SD &               5.7e-03 &                           4.8e-01 &                   7.2e-03 &                      2.1e-02 &                      3.5e-02 &                      2.6e-03 \\
                            & Max &               1.2e+00 &                           3.0e+01 &                   1.1e+00 &                      5.6e+00 &                      1.0e+01 &                      2.3e-01 \\
Linux/Make/Debug/dmpar & Mean &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & SD &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
                            & Max &               0.0e+00 &                           0.0e+00 &                   0.0e+00 &                      0.0e+00 &                      0.0e+00 &                      0.0e+00 \\
Linux/Make/Debug/dm\_sm & Mean &               5.0e-04 &                           1.5e-02 &                   1.9e-04 &                      3.3e-04 &                      2.8e-04 &                      9.4e-05 \\
                            & SD &               3.4e-03 &                           9.2e-02 &                   2.5e-03 &                      4.9e-03 &                      3.3e-03 &                      7.5e-04 \\
                            & Max &               9.9e-01 &                           8.9e+00 &                   4.6e-01 &                      1.1e+00 &                      7.6e-01 &                      1.3e-01 \\
Linux/Make/Debug/smpar & Mean &               3.0e-04 &                           1.3e-02 &                   1.4e-04 &                      1.8e-04 &                      1.8e-04 &                      8.2e-05 \\
                            & SD &               3.0e-03 &                           1.1e-01 &                   1.7e-03 &                      1.6e-03 &                      1.5e-03 &                      8.2e-04 \\
                            & Max &               1.3e+00 &                           1.2e+01 &                   4.7e-01 &                      2.8e-01 &                      2.4e-01 &                      1.4e-01 \\
Linux/Make/Release/dmpar & Mean &               1.8e-03 &                           1.0e-01 &                   7.9e-04 &                      2.2e-03 &                      2.7e-03 &                      4.5e-04 \\
                            & SD &               5.7e-03 &                           4.7e-01 &                   7.1e-03 &                      2.1e-02 &                      3.5e-02 &                      2.6e-03 \\
                            & Max &               1.2e+00 &                           3.0e+01 &                   1.1e+00 &                      5.6e+00 &                      1.0e+01 &                      2.3e-01 \\
Linux/Make/Release/dm\_sm & Mean &               1.8e-03 &                           1.0e-01 &                   7.9e-04 &                      2.2e-03 &                      2.7e-03 &                      4.5e-04 \\
                            & SD &               5.6e-03 &                           4.7e-01 &                   7.1e-03 &                      2.1e-02 &                      3.5e-02 &                      2.6e-03 \\
                            & Max &               1.2e+00 &                           3.0e+01 &                   1.1e+00 &                      5.6e+00 &                      1.0e+01 &                      2.3e-01 \\
Linux/Make/Release/serial & Mean &               1.8e-03 &                           1.0e-01 &                   7.9e-04 &                      2.2e-03 &                      2.7e-03 &                      4.5e-04 \\
                            & SD &               5.7e-03 &                           4.7e-01 &                   7.1e-03 &                      2.1e-02 &                      3.5e-02 &                      2.6e-03 \\
                            & Max &               1.2e+00 &                           3.0e+01 &                   1.1e+00 &                      5.6e+00 &                      1.0e+01 &                      2.3e-01 \\
Linux/Make/Release/smpar & Mean &               1.8e-03 &                           1.0e-01 &                   7.9e-04 &                      2.2e-03 &                      2.7e-03 &                      4.5e-04 \\
                            & SD &               5.7e-03 &                           4.7e-01 &                   7.1e-03 &                      2.1e-02 &                      3.5e-02 &                      2.6e-03 \\
                            & Max &               1.2e+00 &                           3.0e+01 &                   1.1e+00 &                      5.6e+00 &                      1.0e+01 &                      2.3e-01 \\
macOS/CMake/Debug/dmpar & Mean &               2.7e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.5e-03 &                      7.7e-04 \\
                            & SD &               6.8e-03 &                           5.5e-01 &                   8.5e-03 &                      2.7e-02 &                      6.9e-02 &                      3.6e-03 \\
                            & Max &               7.4e-01 &                           3.0e+01 &                   1.1e+00 &                      6.5e+00 &                      1.6e+01 &                      3.6e-01 \\
macOS/CMake/Debug/dm\_sm & Mean &               2.7e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.6e-03 &                      7.8e-04 \\
                            & SD &               7.1e-03 &                           5.5e-01 &                   8.6e-03 &                      2.7e-02 &                      6.9e-02 &                      3.7e-03 \\
                            & Max &               1.3e+00 &                           3.0e+01 &                   1.1e+00 &                      6.5e+00 &                      1.6e+01 &                      3.6e-01 \\
macOS/CMake/Debug/serial & Mean &               2.7e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.5e-03 &                      7.7e-04 \\
                            & SD &               6.8e-03 &                           5.5e-01 &                   8.5e-03 &                      2.7e-02 &                      6.9e-02 &                      3.6e-03 \\
                            & Max &               7.4e-01 &                           3.0e+01 &                   1.1e+00 &                      6.5e+00 &                      1.6e+01 &                      3.6e-01 \\
macOS/CMake/Debug/smpar & Mean &               2.7e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.6e-03 &                      7.8e-04 \\
                            & SD &               6.9e-03 &                           5.5e-01 &                   8.5e-03 &                      2.7e-02 &                      6.9e-02 &                      3.7e-03 \\
                            & Max &               1.3e+00 &                           3.0e+01 &                   1.1e+00 &                      6.5e+00 &                      1.6e+01 &                      3.6e-01 \\
macOS/CMake/Release/dmpar & Mean &               2.8e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.7e-03 &                      8.0e-04 \\
                            & SD &               7.2e-03 &                           6.0e-01 &                   9.2e-03 &                      2.7e-02 &                      9.0e-02 &                      4.3e-03 \\
                            & Max &               1.3e+00 &                           5.1e+01 &                   1.8e+00 &                      6.4e+00 &                      3.9e+01 &                      5.2e-01 \\
macOS/CMake/Release/dm\_sm & Mean &               2.8e-03 &                           1.7e-01 &                   1.4e-03 &                      4.3e-03 &                      5.8e-03 &                      8.1e-04 \\
                            & SD &               7.2e-03 &                           6.0e-01 &                   9.3e-03 &                      2.7e-02 &                      9.0e-02 &                      4.3e-03 \\
                            & Max &               1.3e+00 &                           5.1e+01 &                   1.8e+00 &                      6.4e+00 &                      3.9e+01 &                      5.2e-01 \\
macOS/CMake/Release/serial & Mean &               2.8e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.7e-03 &                      8.0e-04 \\
                            & SD &               7.2e-03 &                           6.0e-01 &                   9.2e-03 &                      2.7e-02 &                      9.0e-02 &                      4.3e-03 \\
                            & Max &               1.3e+00 &                           5.1e+01 &                   1.8e+00 &                      6.4e+00 &                      3.9e+01 &                      5.2e-01 \\
macOS/CMake/Release/smpar & Mean &               2.8e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.7e-03 &                      8.0e-04 \\
                            & SD &               7.2e-03 &                           6.0e-01 &                   9.2e-03 &                      2.7e-02 &                      9.0e-02 &                      4.3e-03 \\
                            & Max &               1.3e+00 &                           5.1e+01 &                   1.8e+00 &                      6.4e+00 &                      3.9e+01 &                      5.2e-01 \\
macOS/Make/Debug/dmpar & Mean &               2.7e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.5e-03 &                      7.7e-04 \\
                            & SD &               6.8e-03 &                           5.5e-01 &                   8.5e-03 &                      2.7e-02 &                      6.9e-02 &                      3.6e-03 \\
                            & Max &               7.4e-01 &                           3.0e+01 &                   1.1e+00 &                      6.5e+00 &                      1.6e+01 &                      3.6e-01 \\
macOS/Make/Debug/dm\_sm & Mean &               2.7e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.6e-03 &                      7.9e-04 \\
                            & SD &               7.1e-03 &                           5.6e-01 &                   8.6e-03 &                      2.7e-02 &                      6.9e-02 &                      3.7e-03 \\
                            & Max &               1.2e+00 &                           3.0e+01 &                   1.1e+00 &                      6.5e+00 &                      1.6e+01 &                      3.6e-01 \\
macOS/Make/Debug/serial & Mean &               2.7e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.5e-03 &                      7.7e-04 \\
                            & SD &               6.8e-03 &                           5.5e-01 &                   8.5e-03 &                      2.7e-02 &                      6.9e-02 &                      3.6e-03 \\
                            & Max &               7.4e-01 &                           3.0e+01 &                   1.1e+00 &                      6.5e+00 &                      1.6e+01 &                      3.6e-01 \\
macOS/Make/Debug/smpar & Mean &               2.7e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.6e-03 &                      7.7e-04 \\
                            & SD &               6.7e-03 &                           5.5e-01 &                   8.5e-03 &                      2.7e-02 &                      6.9e-02 &                      3.6e-03 \\
                            & Max &               7.4e-01 &                           3.0e+01 &                   1.1e+00 &                      6.5e+00 &                      1.6e+01 &                      3.6e-01 \\
macOS/Make/Release/dmpar & Mean &               2.8e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.7e-03 &                      8.0e-04 \\
                            & SD &               7.2e-03 &                           6.0e-01 &                   9.2e-03 &                      2.7e-02 &                      9.0e-02 &                      4.3e-03 \\
                            & Max &               1.3e+00 &                           5.1e+01 &                   1.8e+00 &                      6.4e+00 &                      3.9e+01 &                      5.2e-01 \\
macOS/Make/Release/dm\_sm & Mean &               2.8e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.7e-03 &                      8.0e-04 \\
                            & SD &               7.2e-03 &                           6.0e-01 &                   9.2e-03 &                      2.7e-02 &                      9.0e-02 &                      4.3e-03 \\
                            & Max &               1.3e+00 &                           5.1e+01 &                   1.8e+00 &                      6.4e+00 &                      3.9e+01 &                      5.2e-01 \\
macOS/Make/Release/serial & Mean &               2.8e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.7e-03 &                      8.0e-04 \\
                            & SD &               7.2e-03 &                           6.0e-01 &                   9.2e-03 &                      2.7e-02 &                      9.0e-02 &                      4.3e-03 \\
                            & Max &               1.3e+00 &                           5.1e+01 &                   1.8e+00 &                      6.4e+00 &                      3.9e+01 &                      5.2e-01 \\
macOS/Make/Release/smpar & Mean &               2.8e-03 &                           1.7e-01 &                   1.4e-03 &                      4.2e-03 &                      5.7e-03 &                      8.0e-04 \\
                            & SD &               7.2e-03 &                           6.0e-01 &                   9.2e-03 &                      2.7e-02 &                      9.0e-02 &                      4.3e-03 \\
                            & Max &               1.3e+00 &                           5.1e+01 &                   1.8e+00 &                      6.4e+00 &                      3.9e+01 &                      5.2e-01 \\
Windows/CMake/Debug/dmpar & Mean &               2.7e-03 &                           1.7e-01 &                   1.5e-03 &                      4.4e-03 &                      5.8e-03 &                      8.0e-04 \\
                            & SD &               7.1e-03 &                           6.3e-01 &                   1.0e-02 &                      2.8e-02 &                      8.0e-02 &                      4.1e-03 \\
                            & Max &               8.6e-01 &                           5.5e+01 &                   1.4e+00 &                      6.0e+00 &                      3.1e+01 &                      5.2e-01 \\
Windows/CMake/Debug/dm\_sm & Mean &               2.7e-03 &                           1.7e-01 &                   1.5e-03 &                      4.4e-03 &                      5.8e-03 &                      8.1e-04 \\
                            & SD &               7.1e-03 &                           6.3e-01 &                   1.0e-02 &                      2.8e-02 &                      8.0e-02 &                      4.1e-03 \\
                            & Max &               1.2e+00 &                           5.5e+01 &                   1.4e+00 &                      6.0e+00 &                      3.1e+01 &                      5.2e-01 \\
Windows/CMake/Debug/serial & Mean &               2.7e-03 &                           1.7e-01 &                   1.5e-03 &                      4.4e-03 &                      5.8e-03 &                      8.0e-04 \\
                            & SD &               7.1e-03 &                           6.3e-01 &                   1.0e-02 &                      2.8e-02 &                      8.0e-02 &                      4.1e-03 \\
                            & Max &               8.6e-01 &                           5.5e+01 &                   1.4e+00 &                      6.0e+00 &                      3.1e+01 &                      5.2e-01 \\
Windows/CMake/Debug/smpar & Mean &               2.7e-03 &                           1.7e-01 &                   1.5e-03 &                      4.4e-03 &                      5.8e-03 &                      8.1e-04 \\
                            & SD &               7.2e-03 &                           6.3e-01 &                   1.0e-02 &                      2.8e-02 &                      8.0e-02 &                      4.1e-03 \\
                            & Max &               1.3e+00 &                           5.5e+01 &                   1.4e+00 &                      6.0e+00 &                      3.1e+01 &                      5.2e-01 \\
Windows/CMake/Release/dmpar & Mean &               2.8e-03 &                           1.8e-01 &                   1.6e-03 &                      4.6e-03 &                      6.1e-03 &                      8.3e-04 \\
                            & SD &               7.5e-03 &                           7.1e-01 &                   1.1e-02 &                      3.2e-02 &                      8.6e-02 &                      4.4e-03 \\
                            & Max &               1.2e+00 &                           5.5e+01 &                   1.4e+00 &                      8.2e+00 &                      3.1e+01 &                      5.2e-01 \\
Windows/CMake/Release/dm\_sm & Mean &               2.8e-03 &                           1.8e-01 &                   1.6e-03 &                      4.6e-03 &                      6.1e-03 &                      8.3e-04 \\
                            & SD &               7.5e-03 &                           7.1e-01 &                   1.1e-02 &                      3.2e-02 &                      8.6e-02 &                      4.4e-03 \\
                            & Max &               1.2e+00 &                           5.5e+01 &                   1.4e+00 &                      8.2e+00 &                      3.1e+01 &                      5.2e-01 \\
Windows/CMake/Release/serial & Mean &               2.8e-03 &                           1.8e-01 &                   1.6e-03 &                      4.6e-03 &                      6.1e-03 &                      8.3e-04 \\
                            & SD &               7.5e-03 &                           7.1e-01 &                   1.1e-02 &                      3.2e-02 &                      8.6e-02 &                      4.4e-03 \\
                            & Max &               1.2e+00 &                           5.5e+01 &                   1.4e+00 &                      8.2e+00 &                      3.1e+01 &                      5.2e-01 \\
Windows/CMake/Release/smpar & Mean &               2.8e-03 &                           1.8e-01 &                   1.6e-03 &                      4.6e-03 &                      6.1e-03 &                      8.3e-04 \\
                            & SD &               7.5e-03 &                           7.1e-01 &                   1.1e-02 &                      3.2e-02 &                      8.6e-02 &                      4.4e-03 \\
                            & Max &               1.2e+00 &                           5.5e+01 &                   1.4e+00 &                      8.2e+00 &                      3.1e+01 &                      5.2e-01 \\
\end{longtable}
\end{tiny}

# References


[^1]: By WRF, we specifically mean the Advanced Research WRF (ARW). The Non-hydrostatic Mesoscale Model (NMM) dynamical core, WRF-DA, WRFPLUS, WRF-Chem, and WRF-Hydro are not currently supported in WRF-CMake.

[^2]: Comparison on Windows is not made as Windows support is only available in WRF-CMake.
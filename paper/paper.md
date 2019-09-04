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
The WRF-CMake project provides model developers, code maintainers, and end-users wishing to build WRF and WPS on their system several advantages such as robust incremental rebuilds, dependency analysis of Fortran code, flexible library dependency discovery, automatic construction of compiler command-lines based on the detected compiler, and integrated support for MPI and OpenMP. Furthermore, by using a single language to control the build, CMake removes the need to write and support several hand-written Makefiles, and Perl and Shell scripts. The current WRF-CMake set-up on GitHub offers model developers and code maintainers an automated testing infrastructure (see [Testing](#testing)) for Linux, macOS, and Windows, and allows end-users to directly download pre-built binaries for common configurations and architectures from the project’s website (experimental).
WRF-CMake is available as a free and open-source project on GitHub at [https://github.com/WRF-CMake](https://github.com/WRF-CMake) and currently includes CMake support for the main [Advanced Research WRF (ARW) core](https://github.com/WRF-CMake/WRF) and [WPS](https://github.com/WRF-CMake/WPS).


# Testing

A fundamental aspect of software development is testing. Ideally, model components should be tested individually and under several testing methodologies [@Feathers2004]. Here, however, as the WRF framework does not offer a way to unit test its components, we instead run separate build and regression tests to evaluate the effects of our changes. While build tests are used to check the absence of compilation errors, regression tests are used to estimate the size of simulation errors resulting from our change.

Build tests are performed for all supported build variants (Table 1) using CI services at every commit. As noted by Hodyss and Majumdar [-@Hodyss2007], and Geer [-@Geer2016], the high sensitivity to initial conditions of dynamical systems, such as the ones used in weather models, can lead to large differences in skill between any two forecasts. It is this high sensitivity to initial conditions that can obscure the source of model error, whether this originates from a change in compiler or architecture, an actual coding error, or indeed, the intrinsic nature of the dynamical system employed.

|            | Variant                             |
| ---------- | ----------------------------------- |
| OS         | `Linux`, `macOS`, `Windows`         |
| Build tool | `Make`, `CMake`                     |
| Build type | `Debug`, `Release`                  |
| Mode       | `serial`, `dmpar`, `smpar`, `dm_sm` |

Table: Build variants used in build and regression tests. `Make`: original WRF build system files, `CMake`: this paper; `Debug`: compiler optimizations disabled, `Release`: enabled; `serial`: single processor, `dmpar`: multiple with distributed memory (MPI), `smpar`: multiple with shared memory (OpenMP), `dm_sm`: multiple with MPI and OpenMP.

As a result, the impact of our changes are evaluated using the range-normalized relative percentage error ($\boldsymbol{\delta}_{x}$) and range-normalized root-mean-square percentage error (NRMSPE; Appendix A). These are computed per domain for all grid points, and for all vertical levels. The errors are assessed by (a) comparing the outputs of prognostic-variable outputs (Table 2) from WRF (Make) against those from WRF-CMake and (b) comparing the outputs for all build variants (for both Make and CMake) against a reference build variant defined as `Linux/Make/Debug/serial`.

 These tests are then run for all supported build variants (Table 1) using the [WRF-CMake Automated Testing Suite (WATS)](https://github.com/WRF-CMake/wats), and a subset of namelists[^2] from the official [WRF Testing Framework](https://github.com/wrf-model/WTF), using CI services at major code changes (e.g. before merging pull requests), and for 1 hour of simulation time, to constrain computing resources.

Here, we report summary results for the domain showing the greatest error (i.e. innermost; domain 2) after simulating 60 minutes. Values of $\boldsymbol{\delta}_{x}$ are aggregated for all quantities reported in Table 2 and referred to as $\boldsymbol{\delta}$.

| Symbol           | Name                                  | Unit                   |
| ---------------- | ------------------------------------- | ---------------------- |
| $p$              | Air pressure                          | $\mathsf{Pa}$          |
| $\phi$           | Surface geopotential                  | $\mathsf{m^2\ s^{-2}}$ |
| $\theta$         | Air potential temperature             | $\mathsf{K}$           |
| $\boldsymbol{u}$ | Zonal component of wind velocity      | $\mathsf{m\ s^{-1}}$   |
| $\boldsymbol{v}$ | Meridional component of wind velocity | $\mathsf{m\ s^{-1}}$   |
| $\boldsymbol{w}$ | Vertical component of wind velocity   | $\mathsf{m\ s^{-1}}$   |

Table: WRF prognostic variables evaluated during regression tests.

At the start of the simulation, the NRMSPE between WRF (Make) and WRF-CMake is zero (Appendix B, Figure 5), but small, when comparing WRF build variants (both Make and CMake) against a reference variant (`Linux/Make/Debug/serial`; Appendix B, Figure 6), thus suggesting an expected variability of outputs when running WRF across different platforms.

After 60 minutes (simulation time), WRF-CMake produces, on average, small values of $\boldsymbol{\delta}$, with mean close to zero, and most of the error (99.8 %) between -0.05 and 0.05 % (Figure 1). On Linux, the only build variants showing no error are for `Debug/serial` and  `Debug/dmpar` (Figure 1 and 2). For NRMSPE (Figure 2), values of $\boldsymbol{w}$ show to be the most sensitive, however, the largest errors are shown for all components of wind velocity, on both, Linux and macOS.

Differences, in particular for `Release` build variants, most likely arise from an inconsistent use of compiler optimization options in WRF (Make) across its C and Fortran files, whereas in WRF-CMake, such options are centrally and consistently applied. Given that `Debug/serial` and `Debug/dmpar` show no error, we would expect the same to be true for the OpenMP variants `Debug/smpar` and `Debug/dm_sm`. Further investigation is required to establish the source of these differences.

When comparing both Make and CMake versions against the reference build variant (i.e. `Linux/Make/Debug/serial`; Figure 3 and 4), the errors appear to be of equal, or greater, magnitude than those shown when comparing WRF (Make) against WRF-CMake for both $\boldsymbol{\delta}$ (Figure 3) and NRMSPE (Figure 4), thus indicating that the variability across build variants may be more important and may also be an inherent feature of WRF.

The choice of operating system has the greatest impact on both $\boldsymbol{\delta}$ and NRMSPE (Figure 3 and 4) over compiler optimization strategies and build tool used. A change in build tool to CMake appears to produce values of $\boldsymbol{\delta}$ and NRMSPE consistent with those obtained from versions of WRF built with the original build scripts[^3]. The largest errors are shown for wind velocity and, specifically for $\boldsymbol{u}$ and $\boldsymbol{w}$. Larger values of $\boldsymbol{\delta}$ and NRMSPE between operating systems appear to be a general property of WRF (i.e. with/without CMake support) and should be investigated further.


![WRF (Make) vs WRF-CMake: extended box plots of range-normalized relative percentage errors ($\boldsymbol{\delta}$) for the domain with highest errors only (domain 2) after 60 minutes (simulation time). Extended boxplots show minimum, maximum, median, and percentiles at [99.9, 99, 75, 25, 5, 1, 0.1].](figures/rel_err_ext_boxplot_make_cmake_t6.pdf)


![WRF (Make) vs WRF-CMake: range-normalized root mean-square percentage error (NRMSPE) for the domain with highest errors only (domain 2) after 60 minutes (simulation time).](figures/nrmse_range_make_cmake_t6.pdf)


![WRF (Make and CMake) vs reference build variant: extended box plots of range-normalized relative percentage errors ($\boldsymbol{\delta}$) against the reference build variant (`Linux/Make/Debug/serial`) for the domain with highest errors only (domain 2) after 60 minutes (simulation time). Extended boxplots show minimum, maximum, median, and percentiles at [99.9, 99, 75, 25, 5, 1, 0.1].](figures/rel_err_ext_boxplot_single_ref_t6.pdf)


![WRF (Make and CMake) vs reference build variant: range-normalized root mean-square percentage errors (NRMSPE) against the reference build variant (`Linux/Make/Debug/serial`) for the domain with highest errors only (domain 2) after 60 minutes (simulation time).](figures/nrmse_range_single_ref_t6.pdf)


# Concluding remarks

We introduce WRF-CMake as a modern replacement for the existing WRF build system. Its main goals are to simplify the build process involved in developing and building WRF and WPS, add support for automated testing using CI, and automate the generation of pre-built binary releases for Linux, macOS, and Windows. Results from regression tests indicate that, when evaluating outputs of prognostic variables, errors between WRF and WRF-CMake are generally small, or smaller, then errors originating from a change in optimization strategy (e.g. `Debug`, `Release`) or a change in platform (e.g. Linux to macOS). These larger errors appear to be a general property of WRF (i.e. with/without CMake support) and should be investigated further. Depending on feedback and general uptake by the community, future work may involve adding support for WRF-DA, WRFPLUS, WRF-Chem, and WRF-Hydro.


# Acknowledgements

We thank A. J. Geer at the European Centre for Medium-Range Weather Forecasts (ECMWF) for the useful discussion and feedback concerning the topic of error growth in dynamical systems. We also thank the reviewers I. Beekman and A. Hilboll for their time and useful contributions to both paper and software.

# Appendix A Statistics

The vector of range-normalized relative percentage error ($\boldsymbol{\delta}_{x}$) between two vectors $\boldsymbol{x}_{1}$ and $\boldsymbol{x}_{2}$ of paired quantities $x_{1}$ and $x_{2}$ is defined as:

\begin{equation}
\boldsymbol{\delta}_{x} := \frac{\boldsymbol{x}_{1} - \boldsymbol{x}_{2}}{R_{\boldsymbol{x}_{1}}}\; \times 100\; \%,
\end{equation}

where $R_{\boldsymbol{x}_{1}}$ is the range of $\boldsymbol{x}_{1}$.

Similarly, the range-normalized root-mean-square percentage error (NRMSPE) is defined as:

\begin{equation}
\mathrm{NRMSPE} := \frac{\mathrm{RMSE}}{R_{\boldsymbol{x}_{1}}}\; \times 100\; \%,
\end{equation}

with the root-mean-square-error (RMSE) defined as:

\begin{equation}
    \mathrm{RMSE} := \sqrt{
        \frac{\sum_{i=1}^{N} (\boldsymbol{x}_{1,i} - \boldsymbol{x}_{2,i})^{2}}{N}},
\end{equation}

and $N$ is the size of the vector.

# Appendix B Supplementary figures

![WRF (Make) vs WRF-CMake: range-normalized root mean-square percentage error (NRMSPE) at 0 minutes (simulation time).](figures/nrmse_range_make_cmake_t0.pdf)


![WRF (Make and CMake) vs reference build variant: range-normalized root mean-square percentage errors (NRMSPE) against the reference build variant (`Linux/Make/Debug/serial`) for the domain with highest errors only (domain 2) at 0 minutes (simulation time). Extended boxplots show minimum, maximum, median, and percentiles at [99.9, 99, 75, 25, 5, 1, 0.1].](figures/nrmse_range_single_ref_t0.pdf)

# References



[^1]: By WRF, we specifically mean the Advanced Research WRF (ARW). The Non-hydrostatic Mesoscale Model (NMM) dynamical core, WRF-DA, WRFPLUS, WRF-Chem, and WRF-Hydro are not currently supported in WRF-CMake.

[^2]: See [https://github.com/WRF-CMake/wats/tree/master/cases/wrf](https://github.com/WRF-CMake/wats/tree/master/cases/wrf)

[^3]: Comparison on Windows is not made as Windows support is only available in WRF-CMake.


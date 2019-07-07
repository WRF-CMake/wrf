# Running regression tests locally

In our current GitHub set-up, we perform a series of compilation and regression tests at each commit using the [WRF-CMake Automated Testing Suite](https://github.com/WRF-CMake/wats) on [Windows, macOS, and Linux](https://dev.azure.com/WRF-CMake/wrf/_build).

When you build WRF or WRF-CMake yourself then you have already done a compilation test. If you like to replicate the regression tests, then follow the steps below. The steps assume a Linux or macOS system and may have to be modified for Windows.

**Note:** The following involves downloading 1 GB of reference data and running simulations for 10-30min.

```sh
git clone https://github.com/WRF-CMake/wats.git

# Install Python packages, either via conda:
conda env create -n wats -f wats/environment.yml
conda activate wats
# Or via pip:
pip install -r wats/requirements.txt

# Run test cases
# E.g. for brew: --wrf-dir $(brew --cellar wrf-cmake)/4.1.0/wrf --wps-dir $(brew --cellar wrf-cmake)/4.1.0/wps
python wats/wats/main.py run --mode wrf --mpi --wrf-dir /path/to/wrf --wps-dir /path/to/wps
# Note: replace Linux with macOS/Windows as appropriate
mv wats/work/output wats_Linux_CMake_Release_dmpar

# Download reference data to compare against
# 1. Go to https://dev.azure.com/WRF-CMake/wrf/_build?definitionId=5
# 2. Select a successful build from Branch "wrf-cmake"
# 3. Click on Summary
# 4. Download wats_Linux_Make_Debug_serial build artifact (~1 GB)
# 5. Extract archive to current folder

# Plots
python wats/wats/plots.py compute wats_Linux_Make_Debug_serial wats_Linux_CMake_Release_dmpar
python wats/wats/plots.py plot --skip-detailed
ls wats/plots
# Compare magnitudes in nrmse.png and ext_boxplot.png with plots published in JOSS paper.
```

If you have any issues with the instructions above, please [open an issue](https://github.com/WRF-CMake/wrf/issues/new).
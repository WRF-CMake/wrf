#!/usr/bin/env bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2019 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

SCRIPTDIR=$(dirname "$0")
cd $SCRIPTDIR/../..

if [ "$(uname)" == "Darwin" ]; then

    pip install delocate
    delocate-listdeps --all --depending build/install/main
    delocate-path build/install/main
    delocate-listdeps --all --depending build/install/main

elif [ "$(lsb_release -i -s)" == "CentOS" ]; then

    root_dir=$(cwd)
    tmp_dir=$(mktemp -d)
    cd $tmp_dir

    pip install auditwheel

    echo "from setuptools import setup; setup(name='app', packages=['main'], package_data={'main': ['*.exe']})" > setup.py
    ln -s build/install/main main
    python setup.py bdist_wheel

    # CentOS uses /usr/lib64 but some manually installed dependencies end up in /usr/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib

    auditwheel repair dist/*.whl --no-update-tags
    cd wheelhouse
    unzip *.whl

    # /bin/cp as cp is aliased to 'cp -i' and would ask before overwriting
    /bin/cp -r main/. $root_dir/build/install/main

else
    echo "Unsupported OS: $(uname)"
    exit 1
fi
# See https://docs.microsoft.com/en-gb/azure/devops/pipelines/languages/anaconda.

if [ "$(uname)" == "Darwin" ]; then
    echo "##vso[task.prependpath]$CONDA/bin"
    sudo chown -R $USER $CONDA
elif [ "$(uname)" == "Linux" ]; then
    echo "##vso[task.prependpath]/usr/share/miniconda/bin"
    sudo chown -R $USER /usr/share/miniconda
else
    echo "##vso[task.prependpath]$CONDA\Scripts"
    # We don't use conda activate as we would have to repeat that in each task,
    # as Azure Pipelines does not carry over env vars from one task to the next.
    # Instead, we always use the conda base environment.
    # The following is roughly what "conda activate base" would do.
    # This is about DLL search paths and the fact that python.exe is not
    # in \Scripts but in \. On Linux/macOS things are easier.
    echo "##vso[task.prependpath]$CONDA"
    echo "##vso[task.prependpath]$CONDA\Library\mingw-w64\bin"
    echo "##vso[task.prependpath]$CONDA\Library\bin"
fi

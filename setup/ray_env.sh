#!/bin/bash

# Check if NOBACKUP is set and set RAY_CONDA_ENV_PATH appropriatley if so
if [[ -z "${NOBACKUP}" ]];
then
    echo "\$NOBACKUP is not set. This script is built for use on NCCS Discover \
where \$NOBACKUP should be properly set by default."
    echo "Exiting."
    exit 1
else   
# Set path to for a conda environment to be created on Discover NOBACKUP
    export RAY_CONDA_ENV_PATH="${NOBACKUP}/ray_conda"
fi
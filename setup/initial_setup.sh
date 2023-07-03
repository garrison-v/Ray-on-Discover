#!/bin/bash
# Simple script to setup ray on Discover

# Set path to ray global vars file
RAY_ENV_PATH="./ray_env.sh"
# Check if ray global vars file file exists and source it if it does.
if [[ ! -f "$RAY_ENV_PATH" ]];
then
    echo "${RAY_ENV_PATH} not found. Exiting."
    exit 1
else
    # shellcheck disable=SC1090
    # Source RAY_CONDA_ENV_PATH from ray_env.sh
    if ! source "$RAY_ENV_PATH";
    then
        echo "Error sourcing ${RAY_ENV_PATH}. Exiting."
        exit 1
    fi
fi

# Check if RAY_CONDA_ENV_PATH was properly set by sourcing ray_env.sh
if [[ -z "${RAY_CONDA_ENV_PATH}" ]];
then
    echo "RAY_CONDA_ENV_PATH not set. Exiting."
    exit 1
fi

# Load anaconda module - assume we are on Discover
echo "Loading anaconda module."
if ! module load anaconda;
then
    echo "Error loading anaconda module. Exiting."
    exit 1
fi

# Check if a conda environment has already been created for ray
# or if there is a directory with a conflicting name. Abort either way.
echo "Checking if conda environment for ray exists under ${RAY_CONDA_ENV_PATH}."
if [[ ! -d "${RAY_CONDA_ENV_PATH}" ]];
then
    echo "Creating conda environment for ray under ${RAY_CONDA_ENV_PATH}."
    conda create -y --prefix "${RAY_CONDA_ENV_PATH}"
else
    echo "${RAY_CONDA_ENV_PATH} already exists. Exiting."
    exit 1
fi

# Activate conda environment for ray
echo "Activating conda environment ${RAY_CONDA_ENV_PATH}."
if ! conda activate "${RAY_CONDA_ENV_PATH}";
then
    echo "Error activating conda environment ${RAY_CONDA_ENV_PATH}. Exiting."
    exit 1
fi

# Install pip and use pip to install ray
echo "Installing pip."
if ! conda install -y pip;
then
    echo "Error installing pip. Exiting."
    exit 1
fi
echo "Installing ray."
if ! pip install ray;
then
    echo "Error installing ray. Exiting."
    exit 1
fi

# Finish
printf "\n\n%s" "Ray setup complete!"
printf "\n%s\n" "To use ray, run:"
echo "module load anaconda"
echo "conda activate ${RAY_CONDA_ENV_PATH}"
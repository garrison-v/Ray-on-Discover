# Ray on Discover
## Overview
This repo contains a Ray installation script and an example Slurm job that will: 
- Start a small Ray cluster on Discover
- Submit a simple Ray job to that Ray cluster

As is, this example code is not intended to be used outside of the NCCS Discover cluster.

#### This is example code. Use it at your own risk. Never run code you don't understand on systems you do not own.

## Installation
- Clone this repo into your $NOBACKUP on Discover
- cd into the `setup` directory within the cloned repo
- Run `./initial_setup.sh` to create a new Anaconda environment and install Ray into it

You can customize the path to the Ray Anaconda environment by editing the RAY_CONDA_ENV_PATH 
variable in `setup/ray_env.sh`. 

## Running Ray on Discover
After running the inital setup script once, you can run the example Slurm job to start a Ray 
cluster on Discover.

- cd into the `job` directory within the cloned repo
- Run `sbatch ray_slurm_job.sh` to start the Ray cluster and submit a simple Ray job to it
#!/bin/bash
#SBATCH --job-name=rayTest
#SBATCH --cpus-per-task=4
#SBATCH --nodes=3
#SBATCH --tasks-per-node=1
#SBATCH --time=00:05:00
#SBATCH --account=s2917

# Set path to ray global vars file
RAY_ENV_PATH="../setup/ray_env.sh"
# Must explicity set a temprorary directory and socket paths for ray to use as the default
# on Discover will be too long and throw an error - "OSError: AF_UNIX path length cannot 
# exceed 107 bytes:"
# https://github.com/ray-project/ray/issues/7724
RAY_TEMP_PATH="${NOBACKUP}/ray/t"
RAY_TEMP_PLASMA_SOCKET_PATH="${RAY_TEMP_PATH}/p${RANDOM}"
RAY_TEMP_RAYLET_SOCKET_PATH="${RAY_TEMP_PATH}/r${RANDOM}"

# Check if ray global vars file file exists and source it if it does.
if [[ ! -f "$RAY_ENV_PATH" ]];
then
    echo "${RAY_ENV_PATH} not found. Exiting."
    exit 1
else
    # shellcheck disable=SC1090
    # Source RAY_CONDA_ENV_PATH from ray global vars file
    if ! source "$RAY_ENV_PATH";
    then
        echo "Error sourcing $RAY_ENV_PATH. Exiting."
        exit 1
    fi
fi

# Load anaconda module - assume we are on Discover
module load anaconda
conda activate "$RAY_CONDA_ENV_PATH"

set -x

# Credit: https://docs.ray.io/en/latest/cluster/vms/user-guides/community/slurm-basic.html#slurm-basic
# __doc_head_address_start__

# Getting the node names
nodes=$(scontrol show hostnames "$SLURM_JOB_NODELIST")
nodes_array=("$nodes")

head_node=${nodes_array[0]}
head_node_ip=$(srun --nodes=1 --ntasks=1 -w "$head_node" hostname --ip-address)

# __doc_head_ray_start__
port=6379
ip_head=$head_node_ip:$port
export ip_head
echo "IP Head: $ip_head"

echo "Starting HEAD at $head_node"

# Start head node, specify the temp dir to avoid long path names
srun --nodes=1 --ntasks=1 -w "$head_node" \
  ray start --head --temp-dir="${RAY_TEMP_PATH}" --node-ip-address="$head_node_ip" --port=$port \
    --num-cpus "${SLURM_CPUS_PER_TASK}" --block &
# __doc_head_ray_end__

# __doc_worker_ray_start__
# optional, though may be useful in certain versions of Ray < 1.0.
sleep 30

# number of nodes other than the head node
worker_num=$((SLURM_JOB_NUM_NODES - 1))

for ((i = 1; i <= worker_num; i++)); do
    node_i=${nodes_array[$i]}
    echo "Starting WORKER $i at $node_i"
    # Start compute node(s), specify socket paths to avoid long path names
    srun --nodes=1  --ntasks=1 -w "$node_i" \
      ray start --plasma-store-socket-name="${RAY_TEMP_PLASMA_SOCKET_PATH}" \
        --raylet-socket-name="${RAY_TEMP_RAYLET_SOCKET_PATH}" --address "$ip_head" \
        --num-cpus "${SLURM_CPUS_PER_TASK}" --block &
    sleep 5
done
# __doc_worker_ray_end__

# __doc_script_start__
# ray/doc/source/cluster/doc_code/simple-trainer.py
sleep 30
python -u simple-trainer.py 

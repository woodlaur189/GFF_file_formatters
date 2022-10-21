#!/bin/bash
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=laura.woods1@monash.edu
#SBATCH -c 4
#SBATCH --time=23:00:00
#SBATCH --partition=short
#SBATCH --job-name MetaCHIP

inp_dir="../../MAGs_new_names/"
op_dir="./"
ranks="pcofg"
ext="fa"
conda_source="/monfs00/scratch/lwoo0007/WoodsL/miniconda/bin/activate"
conda_env="/monfs00/scratch/lwoo0007/WoodsL/miniconda/conda/envs/metachip_env"
prefix="Mackay_MAGs_noblast"

source ${conda_source} base
conda activate ${conda_env}

MetaCHIP BP -p ${prefix} -r ${ranks} -t 8

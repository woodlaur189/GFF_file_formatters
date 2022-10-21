#!/bin/bash
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=laura.woods1@monash.edu
#SBATCH -c 6
#SBATCH --time=16:00:00
#SBATCH --partition=short
#SBATCH --job-name blastn_MetaCHIP

source /monfs00/scratch/lwoo0007/WoodsL/miniconda/bin/activate base
conda activate /monfs00/scratch/lwoo0007/WoodsL/miniconda/conda/envs/metachip_env

python PI_blastn_bit.py -u

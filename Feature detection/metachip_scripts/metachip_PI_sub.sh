#!/bin/bash
#SBATCH --account=pa12
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=laura.woods1@monash.edu
#SBATCH -c 8
#SBATCH --time=2:00:00
#SBATCH --partition=comp
#SBATCH --job-name MetaCHIP

inp_dir="../../plasclass/"
op_dir="./"
ranks="pcofg"
ext="fa"
run_blastn="false"

# GTDB taxonomy names must match and not have any extensions.
# This suffix will be added to the end of the names of samples
# in the GTDB-tk taxonomy file
inp_suffix="plasclass"
prefix="Mackay_MAGs_noblast"
# Expects tab-delimited file 
taxonomy_file="Mackay_MAG_taxonomy_GTDB-tk_format.tsv"

# Correct extension if "." added

# Change taxonomy file to map to input sequences
awk -v awk_suffix="_${inp_suffix}" 'BEGIN {FS=OFS="\t"}''FNR>1{$1=$1'awk_suffix'}1' ${taxonomy_file} > metachip_${taxonomy_file}

source /scratch/pa12/lwoo0007/miniconda/bin/activate base
conda activate MetaCHIP_2_env

if [[ $run_blastn="false" ]]
then 
	MetaCHIP PI -p ${prefix} -r ${ranks} -i ${inp_dir} \
	-x ${ext} -taxon metachip_${taxonomy_file} -t 8 -noblast
else
        MetaCHIP PI -p ${prefix} -r ${ranks} -i ${inp_dir} \
        -x ${ext} -taxon metachip_${taxonomy_file} -t 8
fi

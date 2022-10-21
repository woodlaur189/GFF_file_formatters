#!/bin/bash
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=laura.woods1@monash.edu
#SBATCH -c 4
#SBATCH --time=20:00:00
#SBATCH --partition=short
#SBATCH --job-name bigscape_job.sh

conda_source="/monfs00/scratch/lwoo0007/WoodsL/miniconda/bin/activate"
conda_env="/monfs00/scratch/lwoo0007/WoodsL/miniconda/conda/envs/bigscape_env"

source $conda_source base
conda activate $conda_env

inp_dir="../antismash_v6/Mackay_MAGs_all_BGCs/"
label="Mackay_MAGs_antismash_BGCs"
op_dir="Mackay_MAGs_all_antismash_BGCs_w_mibig_bigscape_analysis/"
pfam_dir="../../databases/hmm/Pfam-A_hmms_dir/"

#python bigscape.py -l MS6-5_antismash_BGCs -i /monfs00/scratch/lwoo0007/WoodsL/MS6-5_hybrid_seq_sample/antismash_v6/compiled_antismash_BGCs/all_BGCs/ -o bigscape_MS6-5_all_antismash_BGCs_w_mibig/ --pfam_dir ../../databases/hmm/Pfam-A_hmms_dir/ --mix --mibig
python bigscape.py -l $label -i $inp_dir -o $op_dir --pfam_dir $pfam_dir --mix --mibig

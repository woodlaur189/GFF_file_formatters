#!/bin/bash
#SBATCH -c 4
#SBATCH --mail-user=laura.woods@monash.edu
#SBATCH --time=4:00:00

# Requires abricate

conda_source="/monfs00/scratch/lwoo0007/WoodsL/miniconda/bin/activate"
conda_env="/monfs00/scratch/lwoo0007/WoodsL/miniconda/conda/envs/abricate_env"

inp_dir="../../MAGs/"
op_dir="./Mackay_MAGs/"
ext=".fa"
db="ncbi"
minid=70
mincov=80

# Abricate database versions (abricate --list)
#DATABASE	SEQUENCES	DBTYPE	DATE
#argannot	2223	nucl	2022-May-18
#plasmidfinder	460	nucl	2022-May-18
#farmeDB_filtered_Woods2022	11234	nucl	2022-May-18
#megares	6635	nucl	2022-May-18
#vfdb	2597	nucl	2022-May-18
#card	2631	nucl	2022-May-18
#ecoli_vf	2701	nucl	2022-May-18
#ecoh	597	nucl	2022-May-18
#resfinder	3077	nucl	2022-May-18
#ncbi	5386	nucl	2022-May-18


source $conda_source base
conda activate $conda_env

# Get version
echo abricate --version

# Check output directory
if [ ! -d $op_dir ]
then
    	mkdir $op_dir
fi

# Abricate all MAGs together
# Can be performed for each MAG--see abricate github

abricate ${inp_dir}/*${ext} --minid $minid --mincov $mincov --db $db >> ${op_dir}/abricate_${db}_combined_minid-${minid}_mincov-${mincov}.tsv

# Get abricate summary file for easy heatmaps
abricate --summary ${op_dir}/abricate_${db}_combined.tsv > ${op_dir}/abricate_${db}_combined_minid-${minid}_mincov-${mincov}_summary.tsv

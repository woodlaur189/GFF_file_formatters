#!/bin/bash
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=laura.woods1@monash.edu
#SBATCH -c 4
#SBATCH --time=20:00:00
#SBATCH --partition=short
#SBATCH --job-name digIS

source /monfs00/scratch/lwoo0007/WoodsL/miniconda/bin/activate base
conda activate /monfs00/scratch/lwoo0007/WoodsL/miniconda/conda/envs/digIS_env
module load blast+

inp_dir="../MAGs/"
op_dir="Mackay_MAGs_digIS_ops/"
ext=".fa"

if [ ! -d ${op_dir} ]
then
	mkdir ${op_dir}
fi

for item in ${inp_dir}/*${ext}
do
	sample_name=$(basename "${item}" "${ext}")
	echo ${op_dir}/${sample_name}/results/${sample_name}.sum
        if [ -e ${op_dir}/${sample_name}/results/${sample_name}.sum ]
	then
		echo "Already completed this one"
        else
       		echo "python digIS_search.py -i $item -o ${op_dir}/${sample_name}/"
             	python digIS_search.py -i $item -o ${op_dir}/${sample_name}/
        fi
done



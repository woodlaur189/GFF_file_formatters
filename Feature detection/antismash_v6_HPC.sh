#!/bin/bash

### Antismash v6 for HPC ###
# Location: M3
# Inputs: fasta nt assemblies (folder)

inp_dir="../MAGs/"
op_dir="./"
ext=".fa"
conda_source="/monfs00/scratch/lwoo0007/WoodsL/miniconda/bin/activate"
conda_env="/monfs00/scratch/lwoo0007/WoodsL/miniconda/conda/envs/antismash_env"
script_name="antismash_array_job.sh"
script_name_helper="antismash_array_helper.sh"

if [ ! -d ${op_dir} ]
then
	mkdir ${op_dir}
fi

#Clearing old scripts
if [ -f ${script_name} ]
then
	rm ${script_name}
fi
if [ -f	${script_name_helper} ]
then
	rm ${script_name_helper}
fi

cat << EOF >> ${script_name}
#!/bin/bash
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=laura.woods1@monash.edu
#SBATCH -c 4
#SBATCH --time=06:00:00
#SBATCH --partition=short
#SBATCH --job-name ${script_name}
 
source ${conda_source} base
conda activate ${conda_env}

inp_dir="${inp_dir}"
op_dir="${op_dir}"
ext="${ext}"
EOF

cat << 'EOF' >> ${script_name}

echo "This job in the array has:"
echo "- SLURM_JOB_ID=${SLURM_JOB_ID}"
echo "- SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}"

# grab our filename from a directory listing
FILES=($(ls -1 ${inp_dir}/*${ext}))
FILENAME=${FILES[$SLURM_ARRAY_TASK_ID]}
echo "My input file is ${FILENAME}"

sample=$(basename ${FILENAME} ${ext})

echo "COMMAND: antismash -c 8 --fullhmmer --cb-general --cb-knownclusters --cb-subclusters --asf --pfam2go --smcog-trees --tigrfam --rre --cc-mibig  --html-start-compact --genefinding-tool prodigal-m --output-dir ${op_dir}/${sample}_antismash_all_options/ ${FILENAME}"
antismash -c 8 --fullhmmer --cb-general --cb-knownclusters --cb-subclusters --asf --pfam2go --smcog-trees --tigrfam --rre --cc-mibig --html-start-compact --genefinding-tool prodigal-m --output-dir ${op_dir}/${sample}_antismash_all_options/ ${FILENAME}

echo "Finished"
EOF

cat << EOF >> ${script_name_helper}
#!/bin/bash

inp_dir="${inp_dir}"
op_dir="${op_dir}"
ext="${ext}"

EOF

cat << 'EOF' >> ${script_name_helper}

# get count of files in this directory
NUMFILES=$(ls -1 ${inp_dir}/*${ext} | wc -l)
echo "There are a total of ${NUMFILES} input files"

# subtract 1 as we have to use zero-based indexing (first element is 0)
ZBNUMFILES=$(($NUMFILES - 1))

if [ $ZBNUMFILES != 0 ]; then
	echo "COMMAND: sbatch --array=0-$ZBNUMFILES antismash_array_job.sh"
	sbatch --array=0-$ZBNUMFILES antismash_array_job.sh
else
	echo "No jobs to submit, since no input files in this directory."
fi
EOF

chmod +x ${script_name}
chmod +x ${script_name_helper}

./antismash_array_helper.sh

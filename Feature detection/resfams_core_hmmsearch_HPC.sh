#!/bin/bash

### HMMsearch for HPC ###
# Location: M3
# Inputs: protein sequences (eg. by prodigal)

inp_dir="../../prodigal-M/Mackay_MAGs/"
ext=".faa"
op_dir="./Mackay_MAGs/"
# Ensure versions are the same by using db version from antismash
hmm_db="/monfs00/scratch/lwoo0007/WoodsL/miniconda/conda/envs/antismash_env/lib/python3.8/site-packages/antismash/databases/resfam/Resfams.hmm"
hmm_name=$(basename ${hmm_db} ".hmm")
script_name=${hmm_name}_hmmsearch_array_job.sh
script_name_helper=${hmm_name}_hmmsearch_array_helper.sh
conda_base="/monfs00/scratch/lwoo0007/WoodsL/miniconda/bin/activate"

#Something with hmmer3
conda_env="/monfs00/scratch/lwoo0007/WoodsL/miniconda/conda/envs/hmmer_env"

# A few failsafes
# Make an output directory if it doesn't exist--depends a bit on the program
# as an existing output directory is sometimes required, sometimes isn't, and
# in some cases, if it exists, will derail the program by default

if [ ! -d ${op_dir} ]
then
        mkdir ${op_dir}
fi

if [ "${ext::1}" != "." ];
then
        echo ".${ext}" > $ext
fi
#Clear old scripts
if [ -f $script_name ]
then
        rm $script_name
fi

if [ -f $script_name_helper ]
then
        rm $script_name_helper
fi

cat << EOF >> $script_name
#!/bin/bash
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=laura.woods1@monash.edu
#SBATCH -c 4
#SBATCH --time=1:00:00
#SBATCH --partition=short
#SBATCH --job-name $script_name

source ${conda_base} base
conda activate ${conda_env}

#Inherit variables
inp_dir="${inp_dir}"
op_dir="${op_dir}"
ext="${ext}"
hmm_db="${hmm_db}"
hmm_name="${hmm_name}"
EOF

cat << 'EOF' >> $script_name
echo "This job in the array has:"
echo "- SLURM_JOB_ID=${SLURM_JOB_ID}"
echo "- SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}"

# grab our filename from a directory listing
FILES=($(ls -1 ${inp_dir}/*${ext}))
#### For testing ###
#FILES=$(ls -1 ${inp_dir}/*${ext} | head -n 5)
echo $FILES
FILENAME=${FILES[$SLURM_ARRAY_TASK_ID]}
echo "My input file is ${FILENAME}"

sample_name=$(basename ${FILENAME} ${ext})
# Not sure whether or not to include alignment
echo "COMMAND hmmsearch -o ${sample_name}_${hmm_name}_hmmsearch.out --tblout ${sample_name}_${hmm_name}_hmmsearch.tsv --cut_ga --cpu $SLURM_CPUS_ON_NODE $hmm_db $FILENAME"
hmmsearch -o ${sample_name}_${hmm_name}_hmmsearch.out --tblout ${sample_name}_${hmm_name}_hmmsearch.tsv --cut_ga --cpu $SLURM_CPUS_ON_NODE $hmm_db $FILENAME
EOF

cat << EOF >> $script_name_helper
#!/bin/bash

inp_dir="${inp_dir}"
op_dir="${op_dir}"
ext="${ext}"
script_name="${script_name}"
EOF

cat << 'EOF' >> $script_name_helper
NUMFILES=$(ls -1 ${inp_dir}/*${ext}* | wc -l)
echo "There are a total of ${NUMFILES} input files"
ZBNUMFILES=$(($NUMFILES - 1))
if [ $ZBNUMFILES != 0 ]; then
	echo "COMMAND: sbatch --array=0-$ZBNUMFILES $script_name"
	sbatch --array=0-$ZBNUMFILES $script_name
else
  echo "No jobs to submit--no input files in this directory."
fi
EOF

chmod +x $script_name_helper
./${script_name_helper}

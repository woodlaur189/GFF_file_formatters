#!/bin/bash

### Diamond for HPC ###
# Location: MonARCH
# Inputs: protein sequences (eg. by prodigal)

inp_dir="../prodigal-M/Mackay_MAGs/"
ext=".faa"
op_dir="./Mackay_MAGs"
db_name="Greening_metabolic_marker_genes"
diamond_db_folder="/monfs00/scratch/lwoo0007/WoodsL/databases/Greening_2021_metabolic_marker_genes_databases/metabolic_markers_by_DIAMOND_ID_cutoff/"
conda_source="/monfs00/scratch/lwoo0007/WoodsL/miniconda/bin/activate"
conda_env="/monfs00/scratch/lwoo0007/WoodsL/miniconda/conda/envs/diamond_env"

# User-defined thresholds
evalue=0.000001
query_cov=0.8
max_target_seqs=1

script_name=${db_name}_diamond_array_job.sh
script_name_helper=${db_name}_diamond_array_helper.sh
#conda_base="/scratch/pa12/lwoo0007/miniconda/bin/activate"
#Something with diamond :)
#env="diamond_env"

# A few fail-safes
if [ ! -d ${op_dir} ]
then
        mkdir ${op_dir}
fi

if [ "${ext::1}" != "." ];
then
        echo ".${ext}" > $ext
fi

#Input directory fail-safe HERE!

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

source $conda_source base
conda activate $conda_env

#Inherit variables
folder_suffix="${db_name}"
inp_dir="${inp_dir}"
op_dir="${op_dir}"
ext="${ext}"
diamond_db_folder="${diamond_db_folder}"
evalue="${evalue}"
query_cov="${query_cov}"
max_target_seqs="${max_target_seqs}"
EOF

cat << 'EOF' >> $script_name
echo "This job in the array has:"
echo "- SLURM_JOB_ID=${SLURM_JOB_ID}"
echo "- SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}"

# grab our filename from a directory listing
FILES=($(ls -1 ${inp_dir}/*${ext}))
echo $FILES
FILENAME=${FILES[$SLURM_ARRAY_TASK_ID]}
echo "My input file is ${FILENAME}"

sample_name=$(basename ${FILENAME} ${ext})
echo "Working on ${sample_name}"
mkdir ${op_dir}/${sample_name}_diamond_${folder_suffix}/
for cutoff in 50 60 70 75 80
do
	cutoff_str=$( printf $cutoff )
	db_name="metabolic_markers_DIAMOND_ID_cutoff_${cutoff_str}_diamondDB"
	echo "COMMAND diamond blastp --db ${diamond_db_folder}/${db_name}.dmnd --query ${FILENAME} \
	--out ${op_dir}/${sample_name}_${db_name}_result.tsv --evalue ${evalue} --max-target-seqs ${max_target_seqs} \
	--outfmt 6 qseqid full_qseq sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
	--query-cover ${query_cov}"
	diamond blastp --db ${diamond_db_folder}/${db_name}.dmnd --query ${FILENAME} \
	--out ${op_dir}/${sample_name}_${db_name}_result.tsv --evalue ${evalue} --max-target-seqs ${max_target_seqs} \
	--outfmt 6 qseqid full_qseq sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
	--query-cover ${query_cov}
	diamond blastp --db ${diamond_db_folder}/${db_name}.dmnd --query ${FILENAME} \
	--out ${op_dir}/${sample_name}_${db_name}_result.xml --outfmt 5
	awk -v var="$cutoff" '$4>var' ${op_dir}/${sample_name}_${db_name}_result.tsv > ${op_dir}/${sample_name}_${db_name}_result_pident_${cutoff_str}.tsv

	filtered_results="${op_dir}/${sample_name}_${db_name}_result_pident_${cutoff_str}.tsv"
	cat $filtered_results >> "${sample_name}_diamond_${folder_suffix}_combined_pident_cutoffs.tsv"
	while read -r line
	do
	        query_name=$(echo "${line}" | cut -f 1)
         	query_seq=$(echo "${line}" | cut -f 2)
         	subject=$(echo "${line}" | cut -f 3)
		perc_id=$(echo "${line}" | cut -f 4)
		header=$(echo ">${query_name}_matched_to_${subject}_w_perc_id_${perc_id}")
	        echo "${header}"
        	echo "${query_seq}"
	done < $filtered_results > ${op_dir}/${sample_name}_${db_name}_result"${ext}"
	#while read -r line
	#do
#		query_name=$(echo "${line}" | cut -f 1)
#		subject=$(echo "${line}" | cut -f 3)
#		perc_id=$(echo "${line}" | cut -f 4)
#		header=$(echo "${query_name}_matched_to_${subject}_w_perc_id_${perc_id}")
#		sstart=$(echo "${line}" | cut -f 10)
#		ssend=$(echo "${line}" | cut -f 11)
#		echo -e "${header}\t${sstart}\t${ssend}"
#	done < $filtered_results > ${op_dir}/${sample_name}_${db_name}_filtered_op_for_gff.tsv
#	mv ${op_dir}/${sample_name}_${db_name}_filtered_op_for_gff.tsv ${op_dir}/${sample_name}_diamond_${folder_suffix}/ 
	mv ${op_dir}/${sample_name}_${db_name}_result* ${op_dir}/${sample_name}_diamond_${folder_suffix}/
done

#cat ${op_dir}/${sample_name}_diamond_${folder_suffix}/*filtered_op_for_gff.tsv > ${op_dir}/${sample_name}_diamond_${folder_suffix}/${sample_name}_diamond_${folder_suffix}_combined_for_gff.tsv
cat ${op_dir}/${sample_name}_diamond_${folder_suffix}/*_result"${ext}" > ${op_dir}/${sample_name}_diamond_${folder_suffix}/${sample_name}_diamond_${folder_suffix}_combined.faa
mv ${sample_name}_diamond_${folder_suffix}_combined_pident_cutoffs.tsv ${op_dir}/${sample_name}_diamond_${folder_suffix}/

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

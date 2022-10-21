# For the user to fill in after running MetaCHIP and prodigal seperately (ie not using MetaCHIP prodigal calls)

conda_source="/monfs00/scratch/lwoo0007/WoodsL/miniconda/bin/activate"
conda_env="/monfs00/scratch/lwoo0007/WoodsL/miniconda/conda/envs/seqkit_env"
metachip_all_HGT_faa="Mackay_MAGs_noblast_MetaCHIP_wd/Mackay_MAGs_noblast_combined_pcofg_HGTs_ip90_al200bp_c75_ei80_f10kbp/Mackay_MAGs_noblast_pcofg_detected_HGTs_recipient_genes.faa"
prodigal_folder="../../prodigal-M/Mackay_MAGs/"
op_dir="./"

subfolder_prefix=$(basename $metachip_all_HGT_faa ".faa")
metachip_ids_op_folder="${op_dir}/${subfolder_prefix}_by_sample_metachip_ids/"
prodigal_ids_op_folder="${op_dir}/${subfolder_prefix}_by_sample_prodigal_ids/"

echo $metachip_ids_op_folder

# Output folders
if [ ! -d $op_dir ]
then
	mkdir $op_dir
fi
if [ ! -d $metachip_ids_op_folder ]
then
	mkdir $metachip_ids_op_folder
fi
if [ ! -d $prodigal_ids_op_folder ]
then
	mkdir $prodigal_ids_op_folder
fi

source $conda_source base
conda activate $conda_env

for item in ${prodigal_folder}/*.faa
do
	sample_name=$(basename $item ".faa")
	grep $sample_name $metachip_all_HGT_faa | sed 's/^.//' > ${op_dir}/temp_${sample_name}_ids.txt
	seqkit grep -f ${op_dir}/temp_${sample_name}_ids.txt $metachip_all_HGT_faa | seqkit mutate -p 1:M > ${op_dir}/temp_${sample_name}_mutated.faa
	seqkit common -s ${op_dir}/temp_${sample_name}_mutated.faa ${prodigal_folder}/${sample_name}.faa | seqkit sort -s > ${metachip_ids_op_folder}/${sample_name}.faa
	seqkit common -s ${prodigal_folder}/${sample_name}.faa ${op_dir}/temp_${sample_name}_mutated.faa | seqkit sort -s > ${prodigal_ids_op_folder}/${sample_name}.faa
	rm ${op_dir}/temp_${sample_name}_ids.txt
	rm ${op_dir}/temp_${sample_name}_mutated.faa
done

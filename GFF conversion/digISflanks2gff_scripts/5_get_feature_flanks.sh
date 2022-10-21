digIS_dir="Mackay_MAGs_digIS_ops_combined"
fasta_dir="../MAGs/"
flank_size=10000
op_dir="Mackay_MAGs_digIS_op_combined_flanks_${flank_size}bp_new"
module="bedtools"
ext=".fa"
conda_source="/monfs00/scratch/lwoo0007/WoodsL/miniconda/bin/activate"
conda_env="/monfs00/scratch/lwoo0007/WoodsL/miniconda/conda/envs/seqkit_env"

# Gets flanking regions of IS elements and merges where overlapping
# Outputs a fasta file

if [ ! -d $op_dir ]
then
        mkdir $op_dir
fi

source $conda_source base
conda activate $conda_env
module load ${module}

for item in ${fasta_dir}/*${ext}
do
	sample_name=$(basename $item $ext)
	echo "Working on $sample_name"
	# For re-merged long scaffolds
	#is_gff_file=${digIS_dir}/${sample_name}/results/${sample_name}_remerged_long_scaffs.gff
	# For others
	is_gff_file=${digIS_dir}/${sample_name}/results/${sample_name}.gff
	seqkit fx2tab --length $item --name --only-id > ${op_dir}/${sample_name}_genome_file.tsv
	num_results=$(wc -l < ${is_gff_file})
	if [ "${num_results}" -gt 1 ]
	then
		bedtools flank -i ${is_gff_file} -g ${op_dir}/${sample_name}_genome_file.tsv -l $flank_size -r $flank_size  > ${op_dir}/${sample_name}_${flank_size}bp_flanks.gff
		bedtools sort -i ${op_dir}/${sample_name}_${flank_size}bp_flanks.gff > ${op_dir}/${sample_name}_${flank_size}bp_flanks_sorted.gff
		bedtools merge -i ${op_dir}/${sample_name}_${flank_size}bp_flanks_sorted.gff | awk 'BEGIN {OFS="\t"};{print $1, "digIS", "IS_flank_10000bp", $2+1, $3, ".", ".", ".", "."}' > ${op_dir}/${sample_name}.gff
		head  ${op_dir}/${sample_name}.gff
		rm ${op_dir}/${sample_name}_genome_file.tsv
		rm ${op_dir}/${sample_name}_${flank_size}bp_flanks.gff  
		rm ${op_dir}/${sample_name}_${flank_size}bp_flanks_sorted.gff
		#bedtools getfasta -fi $item -bed ${op_dir}/${sample_name}_${flank_size}bp_flanks_sorted_merged.gff > ${op_dir}/${sample_name}_${flank_size}bp_flanks.fasta
        else
                echo "No IS elements found for: ${sample_name}"
        fi
done

module="bedtools"
fasta_folder="../MAGs/"
ext=".fa"
short_scaff_digIS_ops="Mackay_MAGs_digIS_ops/"
long_scaff_digIS_ops="Mackay_digIS_ops_MAGs_w_long_scaffs_remerged"
op_dir="Mackay_MAGs_digIS_ops_combined"

module load $module

if  [ ! -d ${op_dir} ]
then
	mkdir $op_dir
fi

for item in ${fasta_folder}/*${ext}
do
	sample_name=$(basename $item $ext)
	echo $sample_name
	if [ ! -d ${op_dir}/${sample_name}/results/ ]
	then
		mkdir -p ${op_dir}/${sample_name}/results/
	fi
	short_scaff_file=${short_scaff_digIS_ops}/${sample_name}/results/${sample_name}.gff
	long_scaff_file=${long_scaff_digIS_ops}/${sample_name}/results/${sample_name}_remerged_long_scaffs.gff
	combined_scaff_file=${op_dir}/${sample_name}/results/${sample_name}.gff
	if [ -f ${short_scaff_file} ] && [ -f ${long_scaff_file} ]
	then
		echo "Route 1"
		cat ${short_scaff_file} ${long_scaff_file} > ${combined_scaff_file}
	elif [ -f ${short_scaff_file} ] && [ ! -f ${long_scaff_file} ]
	then
		echo "Route 2"
		cat ${short_scaff_file} > ${combined_scaff_file}
	elif [ ! -f ${short_scaff_file} ] && [ -f ${long_scaff_file} ]
	then
		echo "Route 3"
		cat ${long_scaff_file} > ${combined_scaff_file}
	fi
	bedtools sort -i ${combined_scaff_file} > ${combined_scaff_file/.gff/_sorted.gff}
	bedtools merge -i ${combined_scaff_file/.gff/_sorted.gff} > ${combined_scaff_file/.gff/_sorted_merged.gff}
done	

# Ensure all feature folders have descriptive names
# and all gff files within them are simply sample_name.gff

#main_gff_feature_folder="MS6-5_digIS_op_combined_flanks_10000bp"
#main_gff_feature_folder="metachip_recipient_gffs"
#main_gff_feature_folder="MS6-5_MAGs_metabolic_w_DIAMOND_gffs"
main_gff_feature_folder="Mackay_MAGs_mob_suite_gffs"

inp_fasta_folder="../MAGs/"
ext=".fa"
gff_folder="Mackay_MAGs_gff_feature_folders/"
op_folder="./Mackay_MAGs_gff_intersection_w_mobsuite_plasmids/"
module="bedtools"

module load $module

if [ ! -d $op_folder ]
then
	mkdir $op_folder
fi

main_feature=$(basename $main_gff_feature_folder "/")
for item in ${inp_fasta_folder}/*${ext}
do
	sample_name=$(basename $item $ext)
	gff_features=""
	skip_flag=0
	for feature_folder in ${gff_folder}/*/
	do
	feature=$(basename $feature_folder "/")
		if [ ${feature} == ${main_feature} ]
		then
			echo "Encountered ${gff_folder}/${main_gff_feature_folder}"
			cp ${feature_folder}/${sample_name}.gff ${feature_folder}/${sample_name}_temp.gff
			sed -i '/#.*/d' ${feature_folder}/${sample_name}_temp.gff
			if [ ! -e ${gff_folder}/${main_gff_feature_folder}/${sample_name}.gff ]
			then
				echo "Main feature file doesn't exist--skipping"
				skip_flag=1
			fi
		else
			if [ -e ${feature_folder}/${sample_name}.gff ]
			then
				# Copy and remove annotation lines in gff file (# contig) as they seem to interfere with bedtools
				cp ${feature_folder}/${sample_name}.gff ${feature_folder}/${sample_name}_temp.gff
				sed -i '/#.*/d' ${feature_folder}/${sample_name}_temp.gff
				gff_features+="${feature_folder}/${sample_name}_temp.gff "
				#echo $gff_features
			fi
		fi
	done		
	if [ $skip_flag==1 ]
	then
		#echo "bedtools intersect -loj -a ${gff_folder}/${main_gff_feature_folder}/${sample_name}.gff -b ${gff_features}"
		bedtools intersect -loj -a ${gff_folder}/${main_gff_feature_folder}/${sample_name}_temp.gff -b ${gff_features} > ${op_folder}/${sample_name}.tsv
	fi
	for feature_folder in ${gff_folder}/*/
	do
		if [ -e ${feature_folder}/${sample_name}.gff ]
		then
			rm ${feature_folder}/${sample_name}_temp.gff
		fi
	done
done

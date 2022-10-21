module load bbmap

mkdir MAGs_w_long_scaffs/

for item in ../MAGs/*bin*.fa
do
	sample_name=$(basename $item ".fa")
	cp ${item} ${sample_name}.fa
	sed -i 's/^\(>[^[:space:]]*\).*/\1/' ${sample_name}.fa
	#pyfasta split -n 1 -k 250000 ${sample_name}.fa	
	reformat.sh in=${sample_name}.fa minlength=250000 out=${sample_name}_len_2.5k+.fa
	reformat.sh in=${sample_name}_len_2.5k+.fa fastareadlen=250000 out=${sample_name}_len_2.5k+_split.fa
	rm ${sample_name}_len_2.5k+.fa
	rm ${sample_name}.fa
	mv ${sample_name}_len_2.5k+_split.fa MAGs_w_long_scaffs/${sample_name}_long_scaffs.fa
done

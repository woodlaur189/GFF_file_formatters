#!/bin/bash

### Prodigal for HPC ###
# Location: MonARCH
# Inputs: fasta nt assemblies (folder)

script_name="prodigal-m_job.sh"

inp_dir="../MAGs/"
op_dir="./Mackay_MAGs/"
ext=".fa"

if [ ! -d ${op_dir} ]
then
        mkdir ${op_dir}
fi

#Remove existing script
if [ -f $script_name ]
then
	command rm $script_name
fi

#Make and run prodigal script

cat << 'EOF' >> $script_name
#!/bin/bash
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=laura.woods1@monash.edu
#SBATCH -c 4
#SBATCH --time=4:00:00
#SBATCH --partition=short
#SBATCH --job-name prodigal-m

module load prodigal

EOF

cat << EOF >> $script_name
inp_dir="${inp_dir}"
op_dir="${op_dir}"
ext="${ext}"
EOF

cat << 'EOF' >> $script_name

for item in ${inp_dir}/*${ext}
do
	sample_name=$(basename ${item} ${ext})
	if [[ ! -s ${op_dir}/${sample_name}.faa ]]
	then
		echo "COMMAND prodigal -a ${op_dir}/${sample_name}.faa -d ${op_dir}/${sample_name}.fna -i ${item} -f gff -o ${op_dir}/${sample_name}.gff -p meta -q"
       		prodigal -a ${op_dir}/${sample_name}.faa -d ${op_dir}/${sample_name}.fna -i ${item} -f gff -o ${op_dir}/${sample_name}.gff -p meta -q
	else
		echo "${sample_name} already complete--thanks!" 
	fi

done
EOF

chmod +x $script_name
sbatch $script_name

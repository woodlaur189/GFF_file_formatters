# Requires mobsuite

# I just ran this on commandline because things were taking awhile to queue
# (bad etiquette, I know)
# Nothing too fancy here :)

# Probably smart to add a line to check for completed files 
# in case loop is interrupted

source /fs02/pa12/WoodsL/miniconda/bin/activate base 
conda activate mob_suite_env

# Mob init just needs to be run the first time
#mob_init 

for item in ../MAGs/*bin123.fa
do
        sample_name=$(basename $item ".fa")
        # Mob recon fuses the id and description,
        # so removing decription in temp version
        # However, need file name to remain the same
        # so making a new dir
        mkdir temp_mob_dir_${sample_name}
        cp $item temp_mob_dir_${sample_name}/${sample_name}_temp.fa
        awk '{print $1}' temp_mob_dir_${sample_name}/${sample_name}_temp.fa > temp_mob_dir_${sample_name}/${sample_name}.fa
        #sed -i 's/^\(>[^*\).*/\1/' temp_${sample_name}_for_mob.fa
        mob_recon -o ${sample_name}_recon2/ -i temp_mob_dir_${sample_name}/${sample_name}.fa -c -t
        rm -r temp_mob_dir_${sample_name}/
done


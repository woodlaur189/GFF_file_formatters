from Bio import SeqIO
#import bcbio-gff
import pandas as pd
from glob import glob
import os

inp_folder="./Mackay_MAGs/"
# Pattern that doesn't include the summary file!
file_pattern="abricate*0.tsv"
#inp_file="abricate_card_combined_minid-70_mincov-80.tsv"
op_folder="./Mackay_MAGs_abricate_all_gff_folders/"

#FILE   SEQUENCE        START   END     STRAND  GENE    COVERAGE        COVERAGE_MAP    GAPS    %COVERAGE       %IDENTITY       DATABASE        ACCESSION       PRODUCT RESISTANCE

if os.path.exists("%s/" % op_folder)==False:
	os.mkdir("%s/" % op_folder)

for inp_file in glob("%s*%s" % (inp_folder,file_pattern)):
	print(inp_file)
	subop_folder=inp_file.split('/')[-1].split('.')[0]
	if os.path.exists("%s/%s" % (op_folder, subop_folder))==False:
		os.mkdir("%s/%s" % (op_folder, subop_folder))
	abr_df=pd.read_csv(inp_file, sep='\t')
	filename_list=list(set(abr_df['#FILE'].to_list()))
	for file in filename_list:
		sample_name=file.split("/")[-1].split(".")[0]
		sample_op_file="%s/%s/%s.gff" % (op_folder,subop_folder,sample_name)
		sample_df=abr_df[abr_df['#FILE']==file]
		#open(sample_op_file, 'w')
		sample_handle=open(sample_op_file, 'w')
		#new_record=SeqRecord('', id=
		for row in sample_df.itertuples(index=False):
			contig=str(row[1])
			source=str(row[11])
			feature=str(row[13])
			start=str(row[2])
			end=str(row[3])
			score="."
			strand=str(row[4])
			phase="."
			attribute="Name=%s;ID=%s;product=%s;coverage=%i;identity=%i" % (row[5],row[12],row[14],row[9],row[10])
			new_row="\t".join([contig,source,feature,start,end,score,strand,phase,attribute])
			sample_handle.write(new_row)
			sample_handle.write('\n')
		sample_handle.close()


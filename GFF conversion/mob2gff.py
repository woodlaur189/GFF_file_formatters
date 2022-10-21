from Bio import SeqIO
import os
from glob import glob
import pandas as pd

mob_dir="./"
mob_folder_suffix="_recon"
op_dir="./Mackay_MAGs_mob_suite_gffs/"

if os.path.exists(op_dir)==False:
	os.mkdir(op_dir)

for folder in glob("%s/*%s/" % (mob_dir,mob_folder_suffix)):
	sample_name=folder.split('/')[-2].replace(mob_folder_suffix,'')
	op_file="%s/%s.gff" % (op_dir, sample_name)
	print("Working on %s" % (sample_name))
	plasmid_df=pd.DataFrame(columns=['file_id','sequenceid','attributes'])
	file_ids=[]
	sequenceids=[]
	for plasmid_fasta in glob("%s/*plasmid*fasta" % folder):
		#print(plasmid_fasta)
		plasmid_id=plasmid_fasta.split('/')[-1]
		print(plasmid_id)
		record=SeqIO.read(plasmid_fasta,"fasta")
		contig=record.id.split("|")[1]
		print(contig)
		file_ids.append(plasmid_id)
		sequenceids.append(contig)
	if len(file_ids)==0:
		print("No plasmids found for this sample:%s" % (sample_name))
		continue
	plasmid_df['file_id']=file_ids
	plasmid_df['sequenceid']=sequenceids
	mob_agg_df=pd.read_csv("%s/mobtyper_aggregate_report.txt" % (folder), sep='\t')
	merged_df=plasmid_df.merge(mob_agg_df)
	merged_df['source']=["MOB_suite_recon" for i in range(len(merged_df))]
	merged_df['feature']=["plasmid"	for i in range(len(merged_df))]
	merged_df['start']=[1 for i in range(len(merged_df))]
	merged_df['end']=merged_df['total_length']
	merged_df['score']=["." for i in range(len(merged_df))]
	merged_df['strand']=["." for i in range(len(merged_df))]
	merged_df['phase']=["." for i in range(len(merged_df))]
	att_cols=['rep_type(s)','rep_type_accession(s)','relaxase_type(s)','relaxase_type_accession(s)','mpf_type','mpf_type_accession(s)','orit_type(s)','orit_accession(s)','PredictedMobility','mash_nearest_neighbor','mash_neighbor_distance','mash_neighbor_cluster']
	i=0
	att_list=[]
	for col in att_cols:
		if i==0:
			merged_df['attributes'] =  ("%s=" % (col)) + merged_df[col].astype(str)
			#merged_df[col] = ("%s=" % (col)) + merged_df[col].astype(str)
			merged_df=merged_df.drop(col, axis=1)
		else:
			merged_df['attributes']	=  merged_df['attributes'].astype(str) + (";%s=" % (col)) + merged_df[col].astype(str)
			#merged_df[col] = (";%s=" % (col)) + merged_df[col].astype(str)
			merged_df=merged_df.drop(col, axis=1)
		i+=1
	gff_cols=['sequenceid','source','feature','start','end','score','strand','phase','attributes']
	merged_df=merged_df[gff_cols]
	#print(merged_df)
	#print(op_file)
	#merged_df.to_csv("MS6-5_MAGs_mob_suite_gffs/test.gff", sep="\t", index=False, header=False)
	merged_df.to_csv(op_file, sep="\t", index=False, header=False)
	
		
		

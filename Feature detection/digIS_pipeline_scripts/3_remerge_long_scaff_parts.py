#!/bin/usr/python3

from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.SeqFeature import SeqFeature, FeatureLocation
from BCBio import GFF
from glob import glob
import os

#MS6-5_digIS_ops_MAGs_w_long_scaffs/bin10029a_long_scaffs/results/bin10029a_long_scaffs.gff

inp_folder="Mackay_MAGs_w_long_scaffs_digIS_ops"
inp_label="_long_scaffs"
inp_file_pattern="/results/*_long_scaffs.gff"
op_folder="Mackay_digIS_ops_MAGs_w_long_scaffs_remerged"

for sample_folder in glob("%s/*%s*" % (inp_folder,inp_label)):
	if sample_folder[-1]=="/":
		sample_name=sample_folder.replace(inp_label, '').split('/')[-2]
	elif sample_folder[-1]!="/":
		sample_name=sample_folder.replace(inp_label, '').split('/')[-1]
	print("%s/%s" % (sample_folder,inp_file_pattern))
	in_file=glob("%s/%s" % (sample_folder,inp_file_pattern))[0]
	sample_op_folder="%s/%s/results/" % (op_folder,sample_name)
	os.makedirs(sample_op_folder)
	op_file="%s/%s_remerged_long_scaffs.gff" % (sample_op_folder,sample_name)
	inp_handle = open(in_file)
	op_handle = open(op_file, 'w')
	new_data=[]
	for rec in GFF.parse(inp_handle):
		#new_rec = SeqRecord(rec.seq, rec.id, features=rec.features)
		print(rec.id)
		if '_part_' in rec.id:
			part=rec.id.split('_part_')[-1]
			part_a=int(part)
			new_id=rec.id.split('_part_')[-2]
			part=part_a-1
		else:
			part=0
			new_id=rec.id
		new_features=[]
		for feat in rec.features:
			if feat.type=="transposable_element":
				new_seq=rec.seq
				#print(new_id)
				#print(new_seq)
				#print("TE feature found:")
				#print(feat)
				old_start=feat.location.start
				#print(old_start)
				old_end=feat.location.end
				#print(old_end)
				new_start=int(old_start)+(part*250000)
				#print(new_start)
				new_end=int(old_end)+(part*250000)
				strand=feat.location.strand
				new_feat=SeqFeature(FeatureLocation(new_start, new_end, strand), type="transposable_element",qualifiers=feat.qualifiers)
				#print(new_feat)
				new_features.append(new_feat)
		new_rec=SeqRecord(id=str(new_id),seq=str(new_seq), features=new_features)
		#new_rec.features=new_features
		#print("New rec!")
		#print(new_rec.features)
		new_data.append(new_rec)
	GFF.write(new_data, op_handle)
	inp_handle.close()

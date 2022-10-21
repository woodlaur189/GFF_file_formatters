#!/usr/bin/python3

from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
from BCBio import GFF
from glob import glob

antismash_folder="./"
antismash_label="_antismash_all_options"

for sample_folder in glob("%s/*%s*" % (antismash_folder,antismash_label)):
	if sample_folder[-1]=="/":
		sample_name=sample_folder.replace(antismash_label, '').split('/')[-2]
	elif sample_folder[-1]!="/":
		sample_name=sample_folder.replace(antismash_label, '').split('/')[-1]
	full_antismash_gbk="%s/%s.gbk" % (sample_folder, sample_name)
	inp_handle=open(full_antismash_gbk, "rU")
	op_handle=open("%s/%s.gff" % (sample_folder, sample_name), "w")
	print("Now working on %s...\n" % (sample_name))
	new_data=[]
	# Get the old scaffold name back
	for rec in SeqIO.parse(inp_handle, "genbank"):
		new_id=rec.description.split(' ')[0]
		new_rec = SeqRecord(seq=rec.seq, id=new_id)
		clusters=[]
		for feat in rec.features:
			if feat.type == "protocluster":
				clusters.append(feat)
		new_rec.features=clusters
		if len(new_rec.features) >= 1:
			new_data.append(new_rec)
	#GFF.write(SeqIO.parse(inp_handle, "genbank"), op_handle)
	#recs=[rec for rec in SeqIO.parse(inp_handle, "genbank")]
	#feats=[feat for feat in rec.features if feat.type == "protocluster"]
	GFF.write(new_data, op_handle)


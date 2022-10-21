#!/bin/usr/python3

# Requires Biopython,BCBio-GFF
# Note that you must move the hmm results of interest
# to their own folder

from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.SeqFeature import SeqFeature, FeatureLocation
from BCBio import GFF
from glob import glob
import os

prodigal_folder="../prodigal-M/Mackay_MAGs/"
gff_ext="gff"
#results_folder="/monfs00/scratch/lwoo0007/WoodsL/MS6-5_hybrid_seq_sample/metabolic_gene_characterisation/MS6-5_MAGs/test_diamond_Greening_genes_combined/"
results_folder="Mackay_MAGs/Mackay_MAGs_diamond_Greening_metabolic_marker_genes_pident_cutoffs_for_gff_conversion"
op_folder="Mackay_MAGs_Greening2021_metabolic_w_diamond_gffs/"

# Feature of interest
foi="metabolic_gene_DIAMOND_hit"

# Check that input extension is okay and fix otherwise
if gff_ext[0]!=".":
	gff_ext=".%s" % gff_ext

# Make the ouput folder, if needed
if os.path.exists(op_folder) == False:
	os.mkdir(op_folder)

for gff_file in glob("%s/*%s" % (prodigal_folder, gff_ext)):
	sample_name=gff_file.split("/")[-1].replace(gff_ext, "")
	#blastp_results="../metabolic_gene_characterisation/MS6-5_MAGs/bin10029a_diamond_Greening_metabolic_marker_genes/bin10029a_metabolic_markers_DIAMOND_ID_cutoff_50_diamondDB_result_pident_50.tsv"
	blastp_results=glob("%s/*%s*" % (results_folder, sample_name))[0]
	op_file="%s/%s.gff" % (op_folder, sample_name)
	#op_file="./test_bin10029a_metabolic_DIAMOND_hit_filtered.gff"

	# 1-based indexing
	qseqid_field="1"
	sseqid_field="3"
	pident_field="4"

	qseqid_field=int(qseqid_field)
	sseqid_field=int(sseqid_field)
	pident_field=int(pident_field)

	inp_handle = open(gff_file)
	op_handle = open(op_file, 'w')

	blastp_data=[line.strip('\n') for line in open(blastp_results)]
	#print(blastp_data)

	new_data=[]
	records=[rec for rec in GFF.parse(inp_handle)]
	inp_handle.close()

	# SeqFeature(FeatureLocation(ExactPosition(400247), ExactPosition(400724), strand=-1), type='CDS', id='2_402')]
	for record in records:
		new_features=[]
		#print(record)
		for feat in record.features:
			orf=str(feat.id).split("_")[1]
			#orf=feat.qualifiers["note"].split(";")[0].replace("\"ID=*_","")
			#print(orf)
			feature_coord="%s_%s" % (record.id, orf)
			#print(feature_coord)
			for line in blastp_data:
				#print(line)
				if line.split('\t')[(qseqid_field-1)]==feature_coord:
					print("A MATCH!")
					start=feat.location.start
					end=feat.location.end
					strand=feat.location.strand
					hit=line.split('\t')[(sseqid_field-1)]
					pident=line.split('\t')[(pident_field-1)]
					new_qualifiers={
							"subject":[hit],
							"score":[pident]
							}
					new_feature=SeqFeature(FeatureLocation(start,end,strand),type=foi,qualifiers=new_qualifiers)
					new_features.append(new_feature)
		new_record=SeqRecord(id=str(record.id), seq=str(record.seq),features=new_features)
		new_record.annotations={}
		new_data.append(new_record)
	GFF.write(new_data, op_handle)
	inp_handle.close()	

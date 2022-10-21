#!/bin/usr/python3

from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.SeqFeature import SeqFeature, FeatureLocation
from BCBio import GFF
from glob import glob
import os

prodigal_folder="../../prodigal-M/Mackay_MAGs/"
gff_ext="gff"
results_folder="./Mackay_MAGs/"
hmm_folder_suffix="_Resfams_hmmsearch.tsv"
op_folder="./Mackay_MAGs_resfams_gffs"

if os.path.exists(op_folder) == False:
	os.mkdir(op_folder)

# Feature of interest
foi="resfams_HMMER_hit"

# Check that input extension is okay and fix otherwise
if gff_ext[0]!=".":
	gff_ext=".%s" % gff_ext

qseqid_field="1"
hmmhit_field="3"
score_field="8"
hmmacc_field="4"

qseqid_field=int(qseqid_field)
hmmhit_field=int(hmmhit_field)
score_field=int(score_field)
hmmacc_field=int(hmmacc_field)

for gff_file in glob("%s/*%s" % (prodigal_folder, gff_ext)):
	sample_name=gff_file.split("/")[-1].replace(gff_ext, "")
	print("Working on %s" % (sample_name))
	#blastp_results="../metabolic_gene_characterisation/MS6-5_MAGs/bin10029a_diamond_Greening_metabolic_marker_genes/bin10029a_metabolic_markers_DIAMOND_ID_cutoff_50_diamondDB_result_pident_50.tsv"
	results_file="%s/%s%s" % (results_folder, sample_name,hmm_folder_suffix)
	#print(results_folder)
	op_file="%s/%s.gff" % (op_folder, sample_name)
	#op_file="./test_bin10029a_metabolic_DIAMOND_hit_filtered.gff"

	inp_handle = open(gff_file)
	op_handle = open(op_file, 'w')

	results_data=['\t'.join(line.strip('\n').split()) for line in open(results_file) if line[0]!="#"]
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
			for line in results_data:
				#print(line)
				#print("results line: %s" % (line))
				#print(line.split('\t')[(qseqid_field-1)])
				if line.split('\t')[(qseqid_field-1)]==feature_coord:
					#print("A MATCH!")
					start=feat.location.start
					end=feat.location.end
					strand=feat.location.strand
					hmm_hit=line.split('\t')[(hmmhit_field-1)]
					hmm_accession=line.split('\t')[(hmmacc_field-1)]
					score=line.split('\t')[(score_field)]
					#pident=line.split('\t')[(pident_field-1)]
					new_qualifiers={
							"hit":[hmm_hit],
							"hmm_accession":[hmm_accession],
							"score":[score]
							}
					new_feature=SeqFeature(FeatureLocation(start,end,strand),type=foi,qualifiers=new_qualifiers)
					new_features.append(new_feature)
		new_record=SeqRecord(id=str(record.id), seq=str(record.seq),features=new_features)
		new_record.annotations={}
		new_data.append(new_record)
	GFF.write(new_data, op_handle)
	inp_handle.close()	

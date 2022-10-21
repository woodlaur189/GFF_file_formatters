# Requires Biopython,pandas

from Bio import SeqIO
#import SeqFeature,SeqLocation
from glob import glob
import pandas as pd
import os

fasta_folder="/monfs00/scratch/lwoo0007/WoodsL/Mackay_glacier/MAGs"
ext=".fa"

# Use seqkit common for the metchip faa and prodigal faa
# We lose information from the metachip prodial run, so 
# we have to compare back to our prodigal run to get the
# proper information back out (feature location mostly)

foi="HGT-recipient"

#metachip_folder="/monfs00/scratch/lwoo0007/WoodsL/MS6-5_hybrid_seq_sample/HGT_discovery/metachip/MS6-5_noblast_MetaCHIP_wd/MS6-5_noblast_pcofg_detected_HGTs_donor_genes_by_sample_metachip_ids"
metachip_folder="Mackay_MAGs_noblast_pcofg_detected_HGTs_recipient_genes_by_sample_metachip_ids/"
#prodigal_folder="/monfs00/scratch/lwoo0007/WoodsL/MS6-5_hybrid_seq_sample/HGT_discovery/metachip/MS6-5_noblast_MetaCHIP_wd/MS6-5_noblast_pcofg_detected_HGTs_recipient_genes_by_sample_prodigal_ids"
prodigal_folder="Mackay_MAGs_noblast_pcofg_detected_HGTs_recipient_genes_by_sample_prodigal_ids"
metachip_ext=".faa"
prodigal_ext=".faa"
hgt_file="Mackay_MAGs_noblast_MetaCHIP_wd/Mackay_MAGs_noblast_combined_pcofg_HGTs_ip90_al200bp_c75_ei80_f10kbp/Mackay_MAGs_noblast_pcofg_detected_HGTs.txt"
#hgt_file="/monfs00/scratch/lwoo0007/WoodsL/MS6-5_hybrid_seq_sample/HGT_discovery/metachip/MS6-5_noblast_MetaCHIP_wd/MS6-5_noblast_combined_pcofg_HGTs_ip90_al200bp_c75_ei80_f10kbp/MS6-5_noblast_pcofg_detected_HGTs.txt"
#op_folder="/monfs00/scratch/lwoo0007/WoodsL/MS6-5_hybrid_seq_sample/HGT_discovery/metachip/MS6-5_noblast_MetaCHIP_wd/donor_gffs"
op_folder="Mackay_MAGs_metachip_recipient_gffs"

if "recipient" in str(prodigal_folder):
	partner_prodigal_folder=prodigal_folder.replace("recipient","donor")
	partner_metachip_folder=metachip_folder.replace("recipient","donor")
	donor_bool=False
elif "donor" in str(prodigal_folder):
	partner_prodigal_folder=prodigal_folder.replace("donor","recipient")
	partner_metachip_folder=metachip_folder.replace("donor","recipient")
	donor_bool=True

if os.path.exists(op_folder)==False:
	os.mkdir(op_folder)

all_hgt_df=pd.read_csv(hgt_file, sep='\t')
#print(hgt_df)

for file in glob("%s/*%s*" % (fasta_folder, ext)):
	sample_name=file.split("/")[-1].split(ext)[0]
	if donor_bool==True:
		arrow="%s-->" % (sample_name)
	elif donor_bool==False:
		arrow="-->%s" % (sample_name)
	hgt_df=all_hgt_df[all_hgt_df['direction'].str.contains(arrow)==True]
	print("1. %s" % sample_name)
	print(hgt_df)
	prodigal_file="%s/%s%s" % (prodigal_folder, sample_name, prodigal_ext)
	metachip_file="%s/%s%s"	% (metachip_folder, sample_name, metachip_ext)
	print("2. %s" % prodigal_file)
	print("3. %s" %	metachip_file)
	prodigal_data=[rec for rec in SeqIO.parse(prodigal_file, "fasta")]
	metachip_data=[rec for rec in SeqIO.parse(metachip_file, "fasta")]
	sample_op_file="%s/%s.gff" % (op_folder,sample_name)
	op_handle=open(sample_op_file,'w')
	for rec_p, rec_m in zip(prodigal_data,metachip_data):
		print("New metachip entry: %s" % (rec_m.id))
		print("Working on: %s" % sample_name)
		arrow=""
		orf=rec_p.id.split('_')[-1]
		seqname=rec_p.id.replace("_%s" % (orf),"")
		source="metachip"
		feature="%s" % (foi)
		desc_elements=rec_p.description.replace(" ","").split("#")
		print(desc_elements)
		start=desc_elements[1].strip()
		#print("Start: %s" % (start))
		end=desc_elements[2].strip()
		#print("End: %s" % (end))
		strand=desc_elements[3].strip()
		#print("Strand: %s" % (strand))
		frame="."
		m_id=rec_m.id
		partner_gene_col="Gene_2"
		partner_gene_col_loc=1
		sample_df=hgt_df[hgt_df["Gene_1"]==m_id]
		if len(sample_df)==0:
			sample_df=hgt_df[hgt_df["Gene_2"]==m_id]
			partner_gene_col="Gene_1"
			partner_gene_col_loc=0
		print(sample_df)
		# Handle two recipients/two donors
		att1=desc_elements[4].split(";")[0]
		for row in sample_df.itertuples(index=False):
			print(row)
			score=row[2]
			att2=row[partner_gene_col_loc]
			att3=row[6]
			att4="."
		#score=str(sample_df['Identity'].iloc[0])
		#att1=desc_elements[4].split(";")[0]
		#att2=('').join(sample_df[partner_gene_col].to_list())
		#att3=('').join(sample_df['direction'].to_list())
		#att4=(".")
			partner_sample='_'.join(att2.split("_")[0:-1])
			print(partner_sample)
			partner_prodigal_file="%s/%s%s" % (partner_prodigal_folder, partner_sample, prodigal_ext)
			partner_metachip_file="%s/%s%s" % (partner_metachip_folder, partner_sample, metachip_ext)
			partner_prodigal_data=[rec for rec in SeqIO.parse(partner_prodigal_file, "fasta")]
			partner_metachip_data=[rec for rec in SeqIO.parse(partner_metachip_file, "fasta")]
			for partner_rec_p,partner_rec_m in zip(partner_prodigal_data,partner_metachip_data):
			#print(partner_rec_m.id)
				if partner_rec_m.id==att2:
					print(partner_rec_m.id)
					att4=partner_rec_p.id
					print(att4)
			atts="%s;paired_gene_metachip_id=%s;paired_gene_prodigal_id=%s;direction=%s\n" % (str(att1),str(att2),str(att4),str(att3))
			#print(score)
			#print(end)
			new_line="\t".join([str(prop) for prop in [seqname,source,feature,start,end,score,strand,frame,atts]])
			op_handle.write(new_line)
	op_handle.close()
				
		
		

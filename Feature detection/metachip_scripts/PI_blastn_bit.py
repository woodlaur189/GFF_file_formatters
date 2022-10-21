#!/usr/bin/env python3

# Copyright (C) 2017, Weizhi Song, Torsten Thomas.
# songwz03@gmail.com or t.thomas@unsw.edu.au

# MetaCHIP is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# MetaCHIP is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
import re
import glob
import shutil
import argparse
import warnings
import itertools
from time import sleep
from datetime import datetime
from string import ascii_uppercase
import multiprocessing as mp

import os.path
from Bio.Blast.Applications import NcbiblastnCommandline
warnings.filterwarnings("ignore")

inp_dir= 'Mackay_MAGs_noblast_MetaCHIP_wd/'
prefix = 'Mackay_MAGs_noblast'
ranks = 'pcofg'

print(prefix+'_'+ranks+'_prodigal_output/*ffn')

pwd_prodigal_output_folder='%s/%s_%s_prodigal_output' % (inp_dir, prefix, ranks)
ffn_file_list=[f for f in glob.glob('%s/*ffn' % (pwd_prodigal_output_folder))]
pwd_combined_ffn_file='%s/%s_%s_blastdb/%s_%s_combined_ffn.fasta' % (inp_dir, prefix, ranks, prefix, ranks)
pwd_blast_result_folder='%s/%s_%s_blastn_results/' % (inp_dir, prefix, ranks)

#blast_parameters='-evalue 1e-5 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen" -task blastn -num_threads %s' % 4

# BACKWARDSY-FORWARDSY FOR SLOW SCHEDULING!
ffn_file_list.sort(reverse=True)

for ffn_file in ffn_file_list:
    sample_name=ffn_file.split('/')[-1].replace('.ffn','')
    #print("sample name: %s" % (sample_name))
    ffn_lines=[line for line in open(ffn_file)]
    # Assumes that each sequence is one line
    end_ffn_id=ffn_lines[-2].replace('>','')
    #print("end_ffn: %s" % (end_ffn_id))
    final_blastn_op_file='%s/%s_blastn.tab' % (pwd_blast_result_folder,sample_name)
    #print("blastn_op_file: %s" % (final_blastn_op_file))
    start_flag=''
    if os.path.isfile(str(final_blastn_op_file))==True:
        # Find the query name in the correct column (1st) in the blast file to check if file complete
        blastn_query_lines=[line.split('\t')[0] for line in open(final_blastn_op_file)]
        #print("last blastn query line: %s" % (blastn_query_lines[-1]))
        print( repr(str(end_ffn_id)) )
        print( repr(str(blastn_query_lines[-1])) )
        if str(end_ffn_id).strip('\n') == str(blastn_query_lines[-1]).strip('\n'):
            print("Already done "+str(ffn_file)+"--skipping.\n")
            start_flag='False'
        else:
            start_flag='True'
    else:
        start_flag='True'
    if start_flag=='True':
        print("Now working on "+str(ffn_file)+".\n")
        #blastn_cline = NcbiblastnCommandline(task = 'blastn', query = ffn_file, db = pwd_combined_ffn_file, \
        #outfmt= "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen", \
        #out=str(final_blastn_op_file), num_threads = 32, evalue = 1e-5)
        #stdout, stderr = blastn_cline()
        
        #blastn_cmd = '%s -query %s/%s -db %s -out %s %s -mt_mode 1' % ('blastn', pwd_prodigal_output_folder, str('/'+ffn_file), pwd_combined_ffn_file, pwd_blast_result_fo$
        #os.system(blastn_cmd)

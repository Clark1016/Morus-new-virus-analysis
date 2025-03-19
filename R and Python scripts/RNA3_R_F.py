import pysam
bam_file = "/share/home/zhenghanze/project_plant/Morus/siRNA-confirm/peak/TRINITY_DN55899_c0_g1_i1_siRNA.bam"
output_file = "/share/home/zhenghanze/project_plant/Morus/siRNA-confirm/peak"
contigue_names = ["TRINITY_DN55899_c0_g1_i1_reverse_strand"]
for contigue_name in contigue_names:
	with pysam.AlignmentFile(bam_file, "rb") as bam:
		forward_output_file = f"{contigue_name}_siRNA_forward.bam"	
		reverse_output_file = f"{contigue_name}_siRNA_reverse.bam"	
		forward_bam = pysam.AlignmentFile(forward_output_file, "wb", header=bam.header)
		reverse_bam = pysam.AlignmentFile(reverse_output_file, "wb", header=bam.header)
		for read in bam.fetch(reference = contigue_name):
			if not read.flag & 0x10:
				forward_bam.write(read)
			else:
				reverse_bam.write(read)
		forward_bam.close()
		reverse_bam.close()
		print(f"The result has saved in {forward_output_file} and {reverse_output_file} ." )


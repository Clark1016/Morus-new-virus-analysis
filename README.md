# Morus-new-virus-analysis
## Using Trimmomatic(version 0.39) to remove adapter sequences and low-quality reads.
```
trimmomatic PE ./SY_1.fq.gz ./SY_2.fq.gz -phred33 out_read1.fq read1_unpaired.fq  out_read2.fq read2_unpaired.fq ILLUMINACLIP:/share/home/zhenghanze/miniconda3/envs/trimmomatic/share/trimmomatic/adapters/combined.fasta:2:30:10:8:TRUE LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 -threads 20
```
## Using Trinity(version 2.15.1) assemble the reads with with default parameters using Singularity(version 3.10.0).
```
/share/apps/singularity/3.10.0/bin/singularity exec -e /share/home/zhenghanze/bin/trinityrnaseq.v2.15.1.simg Trinity --seqType fq --left  ./out_read1.fq --right  ./out_read2.fq --output trinity.Morus --max_memory 100G --CPU 40
```
## Perform BLASTX alignment using DIAMOND version 2.1.8, setting the --max-target-seqs parameter to 1 and the --evalue parameter to 1e-20. The database used is the NCBI NR database, last accessed on April 24, 2024.
```
diamond blastx --db ~/database/nr_2024_4_24/nr_v2024_4_24.dmnd -q trinity.Morus.Trinity.fasta -o trinity.nr.Morus --evalue 1e-20  --threads 20 --outfmt 6 qseqid qlen sseqid pident slen qcovhsp scovhsp evalue bitscore sscinames sskingdoms staxids stitle --max-target-seqs 1
```
## Using Bowtie2(version 2.2.5 12) map reads were back to the viral genomes  and SAMtools(version 1.6) to calculate depth of scaffolds.
```
bowtie2-build  ./trinity.Morus.Trinity.fasta ./index/Morus_trans
bowtie2 -p 20  -x ./index/Morus_trans -q -1 SY_1.fq.gz -2 SY_2.fq.gz -S Morus.sam
source /share/home/zhenghanze/miniconda3/etc/profile.d/conda.sh
conda activate /share/home/zhenghanze/miniconda3/envs/samtools
samtools view -bS -h Morus.sam -o Morus.bam -@ 20
samtools sort Morus.bam -o Morus.sort.bam -@ 20
samtools index Morus.sort.bam
samtools view -b Morus.sort.bam  TRINITY_DN7047_c0_g2_i1 > TRINITY_DN7047_c0_g2_i1.bam
samtools depth -d 300000 TRINITY_DN7047_c0_g2_i1.bam > TRINITY_DN7047_c0_g2_i1.depth
awk '{ sum += $3 } END { if (NR > 0) print sum / NR }' TRINITY_DN7047_c0_g2_i1.depth > TRINITY_DN7047_c0_g2_i1_converage.txt
```
## Cutadapt(version 4.9) played a role in the removal of adapter sequences and low-quality reads from raw data The sequence "AGATCGGAAGAGCACACGTCT" is the 3' end adapter sequence.
```
cutadapt -a AGATCGGAAGAGCACACGTCT -m 1 SY_siRNA.fq.gz > Morus.fq.cutadapt.gz
```
## Using Bowtie(version 12.4.0) align the resulted sequence to viral genome.
```
bowtie-build  ./trinity.Morus.Trinity.fasta ./index/Morus_siRNA
bowtie -p 20 -n 1 -l 10 -m 100 -k 1 --best --strata  -x ./index/Morus_siRNA -q Morus.fq.cutadapt.gz -S Morus_siRNA.sam
samtools view -bS -h Morus_siRNA.sam -o Morus_siRNA.bam -@ 20
samtools sort Morus_siRNA.bam -o Morus_siRNA.sort.bam -@ 20
samtools index Morus_siRNA.sort.bam
```

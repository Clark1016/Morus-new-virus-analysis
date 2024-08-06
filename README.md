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
## Using Bowtie2(version 2.2.5 12) and SAMtools(version 1.6) map reads were back to the viral genomes, calculate depth of viruses genomes with mosdeoth(version 0.3.6).
```
bowtie2-build  ./trinity.Morus.Trinity.re.fasta ./index/Morus_trans
bowtie2 -p 20  -x ./index/Morus_trans -q -1 SY_1.fq.gz -2 SY_2.fq.gz -S Morus.sam
source /share/home/zhenghanze/miniconda3/etc/profile.d/conda.sh
conda activate /share/home/zhenghanze/miniconda3/envs/samtools
samtools view -S -b -F 4 Morus.sam > Morus.bam
samtools sort Morus.bam -o Morus.sort.bam -@ 20
samtools index Morus.sort.bam
samtools view -b Morus.sort.bam TRINITY_DN7047_c0_g2_i1_reverse_strand > TRINITY_DN7047_c0_g2_i1.bam
samtools view -b Morus.sort.bam TRINITY_DN12393_c0_g1_i1 > TRINITY_DN12393_c0_g1_i1.bam
samtools view -b Morus.sort.bam TRINITY_DN55899_c0_g1_i1_reverse_strand > TRINITY_DN55899_c0_g1_i1.bam
samtools view -b Morus.sort.bam TRINITY_DN8130_c0_g1_i1 > TRINITY_DN8130_c0_g1_i1.bam
samtools index TRINITY_DN7047_c0_g2_i1.bam
samtools index TRINITY_DN12393_c0_g1_i1.bam
samtools index TRINITY_DN55899_c0_g1_i1.bam
samtools index TRINITY_DN8130_c0_g1_i1.bam
source /share/home/zhenghanze/miniconda3/etc/profile.d/conda.sh
conda activate /share/home/zhenghanze/miniconda3/envs/mosdepth
mosdepth -t 20 --fast-mode TRINITY_DN7047_c0_g2_i1.depth TRINITY_DN7047_c0_g2_i1.bam
mosdepth -t 20 --fast-mode TRINITY_DN12393_c0_g1_i1.depth TRINITY_DN12393_c0_g1_i1.bam
mosdepth -t 20 --fast-mode TRINITY_DN55899_c0_g1_i1.depth TRINITY_DN55899_c0_g1_i1.bam
mosdepth -t 20 --fast-mode TRINITY_DN8130_c0_g1_i1.depth TRINITY_DN8130_c0_g1_i1.bam
```
## Cutadapt(version 4.9) played a role in the removal of adapter sequences and low-quality reads from raw data The sequence "AGATCGGAAGAGCACACGTCT" is the 3' end adapter sequence.
```
cutadapt -a AGATCGGAAGAGCACACGTCT -m 1 SY_siRNA.fq.gz > Morus.fq.cutadapt.gz
```
## Using Bowtie(version 12.4.0) align the resulted sequence to viral genome.
```
source /share/home/zhenghanze/miniconda3/etc/profile.d/conda.sh
conda activate /share/home/zhenghanze/miniconda3/envs/bowtie
bowtie-build  ./trinity.Morus.Trinity.re.fasta ./index/Morus_siRNA
bowtie -p 20 -n 1 -l 10 -m 100 -k 1 --best --strata  -x ./index/Morus_siRNA -q Morus.fq.cutadapt.gz -S Morus_siRNA.sam
source /share/home/zhenghanze/miniconda3/etc/profile.d/conda.sh
conda activate /share/home/zhenghanze/miniconda3/envs/samtools
samtools view -S -b -F 4 Morus_siRNA.sam > Morus_siRNA.bam
samtools sort Morus_siRNA.bam -o Morus_siRNA.sort.bam -@ 20
samtools index Morus_siRNA.sort.bam
```
## USing SAMtools(version 1.6) and mosdepth(version 0.3.6) to calculate siRNA depth corresponding to the genome.
```
source /share/home/zhenghanze/miniconda3/etc/profile.d/conda.sh
conda activate /share/home/zhenghanze/miniconda3/envs/samtools
samtools view -b Morus_siRNA.sort.bam TRINITY_DN7047_c0_g2_i1_reverse_strand > TRINITY_DN7047_c0_g2_i1_siRNA.bam
samtools view -b Morus_siRNA.sort.bam TRINITY_DN12393_c0_g1_i1 > TRINITY_DN12393_c0_g1_i1_siRNA.bam
samtools view -b Morus_siRNA.sort.bam TRINITY_DN55899_c0_g1_i1_reverse_strand > TRINITY_DN55899_c0_g1_i1_siRNA.bam
samtools view -b Morus_siRNA.sort.bam TRINITY_DN8130_c0_g1_i1 >  TRINITY_DN8130_c0_g1_i1_siRNA.bam
samtools index TRINITY_DN8130_c0_g1_i1_siRNA.bam
samtools index TRINITY_DN7047_c0_g2_i1_siRNA.bam
samtools index TRINITY_DN12393_c0_g1_i1_siRNA.bam
samtools index TRINITY_DN55899_c0_g1_i1_siRNA.bam
source /share/home/zhenghanze/miniconda3/etc/profile.d/conda.sh
conda activate /share/home/zhenghanze/miniconda3/envs/mosdepth
mosdepth -t 20 --fast-mode TRINITY_DN7047_c0_g2_i1_siRNA.depth TRINITY_DN7047_c0_g2_i1_siRNA.bam
mosdepth -t 20 --fast-mode TRINITY_DN12393_c0_g1_i1_siRNA.depth TRINITY_DN12393_c0_g1_i1_siRNA.bam
mosdepth -t 20 --fast-mode TRINITY_DN55899_c0_g1_i1_siRNA.depth TRINITY_DN55899_c0_g1_i1_siRNA.bam
mosdepth -t 20 --fast-mode TRINITY_DN8130_c0_g1_i1_siRNA.depth TRINITY_DN8130_c0_g1_i1_siRNA.bam
```
## The phylogenetic analysis hinged on the amino acid sequences of the predicted large protein (L), nucleocapsid protein (N) and putative viral movement protein (M).
```
source /share/home/zhenghanze/miniconda3/etc/profile.d/conda.sh
conda activate /share/home/zhenghanze/miniconda3/envs/iqtree
mafft --auto merged_ORF_L.fasta > merged_ORF_L.mafft.fasta
trimal -in merged_ORF_L.mafft.fasta -out merged_ORF_L.mafft.trimal.fasta -automated1
iqtree -s merged_ORF_L.mafft.trimal.fasta -T auto -m MFP -b 1000 -redo
mafft --auto merged_ORF_M.fasta > merged_ORF_M.mafft.fasta
trimal -in merged_ORF_M.mafft.fasta -out merged_ORF_M.mafft.trimal.fasta -automated1
iqtree -s merged_ORF_M.mafft.trimal.fasta -T auto -m MFP -b 1000 -redo
mafft --auto merged_ORF_N.fasta > merged_ORF_N.mafft.fasta
trimal -in merged_ORF_N.mafft.fasta -out merged_ORF_N.mafft.trimal.fasta -automated1
iqtree -s merged_ORF_N.mafft.trimal.fasta -T auto -m MFP -b 1000 -redo
```


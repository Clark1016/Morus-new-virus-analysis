#!/bin/bash
#SBATCH -p rack,rack2     # 投递任务的队列 fat，rack，rack2, d2
#SBATCH --mem=100G # 所需的内存大小
#SBATCH -N 1       # 1个节点，一般不需要修改
#SBATCH -n 20      # 所需的CPU的数量
#SBATCH -e iqtree.sh.e%j # 错误输出
#SBATCH -o iqtree.sh.o%j # 标准输出
source /share/home/zhenghanze/miniconda3/etc/profile.d/conda.sh
conda activate /share/home/zhenghanze/miniconda3/envs/iqtree
mafft --auto merged_ORF_L.fasta > merged_ORF_L.mafft.fasta
trimal -in merged_ORF_L.mafft.fasta -out merged_ORF_L.mafft.trimal.fasta -automated1
iqtree -s merged_ORF_L.mafft.trimal.fasta -T auto -m MFP -b 1000 -redo

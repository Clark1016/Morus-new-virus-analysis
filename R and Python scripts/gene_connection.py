import sys
from Bio import SeqIO
import os
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord

def read_species_list(file_path):
    with open(file_path, 'r') as file:
        return [line.strip() for line in file if line.strip()]

def concatenate_sequences(input_dir, output_file, species_list, file_suffix):
    # 为每个物种创建一个字典，存储其序列和来源文件的名称
    species_sequences = {species: {"sequence": "", "files": []} for species in species_list}

    # 获取所有文件并按字母顺序排序
    all_files = sorted([f for f in os.listdir(input_dir) if f.endswith(file_suffix)])

    # 按排序后的文件顺序遍历目录中的所有文件
    for filename in all_files:
        file_path = os.path.join(input_dir, filename)

        # 初始化当前文件的物种序列字典
        file_sequences = {species: "" for species in species_list}

        # 读取文件中的所有序列
        with open(file_path, 'r') as fasta_file:
            for record in SeqIO.parse(fasta_file, 'fasta'):
                species_id = record.id
                #species_id = record.id.split("_")[0] + "_" + record.id.split("_")[1]
                if species_id in species_sequences:
                    file_sequences[species_id] = str(record.seq)
                    species_sequences[species_id]["files"].append(filename)

        # 获取最长序列的长度
        max_length = max(len(seq) for seq in file_sequences.values() if seq)

        # 为每个物种的序列添加填充（此处我们使用'-'来填充）
        for species in species_list:
            if file_sequences[species]:
                padding_length = max_length - len(file_sequences[species])
                species_sequences[species]["sequence"] += file_sequences[species] + '-' * padding_length
            else:
                # 如果在当前文件中没有找到该物种的序列，则整个长度使用填充字符
                species_sequences[species]["sequence"] += '-' * max_length

    # 输出所有串联后的序列到一个文件
    with open(output_file, 'w') as output_handle:
        for species, seq_info in species_sequences.items():
            # 如果没有找到序列，则文件名列表为空，我们使用'null'来表示这种情况
            file_names = ';'.join(seq_info["files"]) if seq_info["files"] else 'X'
            description = f"{species};{file_names}"

            # 确保序列是有效的Seq对象
            if seq_info["sequence"]:
                sequence_str = seq_info["sequence"]
            else:
                sequence_str = ""  # 或者其他表示无效序列的方式，例如'-' * expected_length

            # 创建Bio.SeqRecord对象来存储序列，含有序列名和来源文件名的描述
            seq_record = SeqRecord(Seq(sequence_str), id=species, description=description)

            # 写入FASTA文件
            SeqIO.write(seq_record, output_handle, 'fasta')


if __name__ == "__main__":
    if len(sys.argv) < 5:
        print("Usage: python script.py <input_directory> <output_file> <file_suffix> <species_list_file>")
        sys.exit(1)

    input_dir = sys.argv[1]
    output_file = sys.argv[2]
    file_suffix = sys.argv[3]
    species_list_file = sys.argv[4]

    species_list = read_species_list(species_list_file)

    concatenate_sequences(input_dir, output_file, species_list, file_suffix)
# python concatenate_sequences.py input_dir output_file file_suffix species_list_file

# 加载必要的 R 包
library(ggplot2)
library(cowplot)  # 用于拼接图形
setwd("H:/Project/project_Morus_virus/depth_total/RNA-seq_depth")
# 定义输入文件路径和 RNA 名称
input_files <- c("TRINITY_DN7047_c0_g2_i1.depth.list", 
                 "TRINITY_DN8130_c0_g1_i1.depth.list", 
                 "TRINITY_DN55899_c0_g1_i1.depth.list")  # 替换为实际文件名
genome_lengths <- c(7320, 1262, 1202)  # RNA1, RNA2, RNA3 的基因组长度
rna_names <- c("RNA1", "RNA2", "RNA3")  # RNA 名称

# 定义一个函数来读取文件并标记 RNA 名称
read_and_label <- function(file_path, rna_name, genome_length) {
  data <- read.table(file_path, header = TRUE)  # 假设输入文件有表头
  data <- data[, c("bp", "depth")]
  data <- data %>%
    filter(bp <= genome_length) %>%  # 确保只包含在基因组范围内的数据
    mutate(rna = rna_name)
  data
}

# 读取文件并添加 RNA 名称标签
depth_data_list <- mapply(
  read_and_label,
  input_files,
  rna_names,
  genome_lengths,
  SIMPLIFY = FALSE
)

# 合并所有 RNA 的数据
depth_data <- bind_rows(depth_data_list)

# 定义颜色映射
rna_colors <- c("RNA1" = "#009E73", "RNA2" = "#56B4E9", "RNA3" = "#E69F00")

# 初始化空列表，用于保存每个 RNA 的单独图形
plot_list <- list()

# 最大基因组长度，用于统一比例
max_genome_length <- max(genome_lengths)

# 为每个 RNA 分别绘制图形
# 为每个 RNA 分别绘制图形
for (i in seq_along(rna_names)) {
  # 筛选当前 RNA 的数据
  rna_data <- depth_data %>% filter(rna == rna_names[i])
  
  # 绘制当前 RNA 的深度图
  p <- ggplot(data = rna_data, aes(x = bp, y = depth, fill = rna, group = rna)) +
    geom_area(alpha = 0.6, color = NA, position = "identity") +  # 去除描边
    scale_x_continuous(
      name = "Genome length",  # 修改横坐标标题
      limits = c(0, max_genome_length),  # 横坐标范围统一到最大基因组长度
      breaks = scales::pretty_breaks(n = 5)
    ) +
    scale_y_continuous("Depth") +
    ggtitle(rna_names[i]) +
    scale_fill_manual(values = rna_colors) +
    theme_minimal() +
    theme(
      plot.title = element_text(family = "Arial", face = "bold", size = 16, hjust = 0.5),
      axis.text = element_text(family = "Arial", size = 12),
      axis.title = element_text(family = "Arial", size = 14),
      legend.position = "none",  # 去除图注
      plot.margin = margin(10, 10, 10, 10)  # 调整图形间距
    )
  
  # 将绘制的图形保存到列表中
  plot_list[[i]] <- p
}
# 使用 cowplot::plot_grid 将图按列排列，横坐标视觉宽度统一
plot_combined <- plot_grid(
  plotlist = plot_list,
  ncol = 1,  # 按列排列
  align = "v"  # 垂直对齐
)

# 保存最终合并图
ggsave("RNA-seq_depth.svg", plot_combined, width = 12, height = 12)

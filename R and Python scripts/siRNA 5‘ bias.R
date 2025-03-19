# 加载所需的 R 包
library(ggplot2)

# 加载必要的 R 包
library(ggplot2)
library(dplyr)
setwd("H:/Project/project_Morus_virus/peak")
# 读取 CSV 文件并为每个文件添加标识符列
file1 <- read.csv("RNA1.siRNA.base_bias.csv") %>%
  mutate(Source = "RNA1")

file2 <- read.csv("RNA2.siRNA.base_bias.csv") %>%
  mutate(Source = "RNA2")

file3 <- read.csv("RNA3.siRNA.base_bias.csv") %>%
  mutate(Source = "RNA3")

# 合并三个文件
combined_data <- bind_rows(file1, file2, file3)

# 绘制堆叠柱状图
ggplot(combined_data, aes(x = Source, y = Count, fill = Base)) +
  geom_bar(stat = "identity") +  # 用统计值（Count）绘制柱状图
  theme_minimal() +  # 使用简洁主题
  labs( x = "5' base bias", y = "base count") +  # 添加标题和坐标轴标签
  scale_fill_manual(values = c("A" = "#99CCFF", "U" = "#99CC33", "C" = "#9999CC", "G" = "#999966")) +  # 自定义颜色
  theme(legend.title = element_blank()) +  # 去掉图例标题
  theme(legend.position = "bottom")  # 将图例放到底部


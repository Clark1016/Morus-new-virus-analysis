library(ggplot2)
library(tidyr)
library(showtext)
showtext_auto()
font_add("Arial", regular = "C:/Windows/Fonts/arial.ttf") 
setwd("F:/Project/project_Morus_virus/depth_total/RNA-seq_depth")
prefix <- "TRINITY_DN55899_c0_g1_i1"
depth_data <- read.table(paste0(prefix, ".depth.list"), header = T)
RAW_data <- depth_data[, c("bp", "depth")]
# 绘制图形时使用合并后的数据
depth_plot <- ggplot(data = RAW_data, aes(x = bp, y = depth)) +
  geom_area(linetype = "solid", linewidth = 1, alpha = 1, fill = "#E69F00") +
  ggtitle("RNA3") +
  theme(plot.title = element_text(family = "Arial",       # 指定字体
                                  face = "bold",         # 指定字体加粗
                                  size = 18,             # 指定字体大小
                                  color = "black",       # 指定字体颜色
                                  hjust = 0.5)           # 水平对齐方式，0.5表示居中对齐
  ) +
  ylim(0, 300000) +  
  xlab("Position") +   
  ylab("Depth") +   
  theme(
    panel.background = element_rect(fill = "white"),
    axis.text = element_text(family = "Arial", face = "bold", size = 20),
    axis.title = element_text(family = "Arial", face = "bold", size = 22)
  ) + 
  scale_y_continuous(expand = expansion(mult = c(0, 0.03)), labels = scales::comma, breaks = seq(0, 300000, by = 100000)) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.03)), breaks = seq(from = 0, to = 300000, by = 200))
ggsave("RNA3.svg", plot = depth_plot, width = 8, height = 6, units = "in")
# 显示图形
print(depth_plot)


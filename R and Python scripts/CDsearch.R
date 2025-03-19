library(ggplot2)
library(tidyr)
library(showtext)
library(gggenes)
library(scales)  # For breaks_width

# Enable showtext to render custom fonts
showtext_auto()
font_add("Arial", regular = "C:/Windows/Fonts/arial.ttf") 

# Set working directory
setwd("H:/Project/project_Morus_virus/CDsearch")

# Combine data for all genes (RNA1, RNA2, RNA3)
data_combined <- data.frame(
  molecule = c("RNA1", "RNA2", "RNA3"),
  gene = c("L", "Mp", "N"),
  start = c(104, 153, 284),
  end = c(7285, 1169, 1132),
  strand = c("reverse", "reverse", "reverse"),
  label_pos = c(3650, 806, 900)  # Custom label positions for better alignment
)

# Compute the scale for the x-axis based on the longest gene
max_end <- max(data_combined$end)
min_start <- min(data_combined$start)

# Create the plot
gene_arrow_plot <- ggplot(data_combined, aes(xmin = start, xmax = end, y = molecule, fill = gene, label = gene)) +
  geom_gene_arrow(arrowhead_height = unit(3, "mm"), arrowhead_width = unit(1.5, "mm"), size = 0.3) +
  geom_gene_label(data = data_combined, aes(x = label_pos), label_fontsize = 6) +  # Adjust label position and font size
  facet_wrap(~ molecule, scales = "free", ncol = 1) +  # Place each RNA in a separate row
  scale_fill_manual(values = c("L" = "pink", "Mp" = "white", "N" = "lightblue")) +  # Custom colors for each gene
  scale_x_continuous(
    expand = c(0, 0),   # Remove the default padding on x-axis
    limits = c(min_start, max_end),  # Adjust x-axis limits based on gene start and end
    breaks = breaks_width(1000)  # Set custom breaks, adjust the number to control tick spacing
  ) +
  theme_genes() +
  theme(
    text = element_text(family = "Arial"),   
    axis.text = element_text(size = 10),    # Reduce axis text size
    axis.title = element_text(size = 12),   
    legend.text = element_text(size = 12),  
    legend.title = element_text(size = 14), 
    strip.text = element_text(size = 14)    
  )

# Save the combined plot
ggsave("CDsearch.svg", plot = gene_arrow_plot, width = 12, height = 6, units = "in")

# Print the combined plot
print(gene_arrow_plot)

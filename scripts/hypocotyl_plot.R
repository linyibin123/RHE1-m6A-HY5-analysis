# =========================================================
# Hypocotyl height analysis and visualization
# Supplementary Figure script
# Author: Yibin Lin
# =========================================================

# Clear environment
rm(list = ls())

# Load required packages
library(readxl)
library(ggplot2)
library(ggsignif)
library(dplyr)
library(tidyr)

# =========================================================
# 1. Load data (use relative path for GitHub reproducibility)
# =========================================================
# Place your data file in a folder named "data"
file_path <- "data/AT5G43140_Hypocotyl_Height.xlsx"
data <- read_excel(file_path, sheet = "Sheet1")

# =========================================================
# 2. Data transformation
# =========================================================
data_long <- data %>%
  pivot_longer(
    cols = everything(),
    names_to = "Condition",
    values_to = "Hypocotyl_Height"
  ) %>%
  mutate(
    # Extract genotype and time point
    Genotype = sub("_(\\d+DAG)", "", Condition),
    DAG = sub(".*_(\\d+DAG)", "\\1", Condition),
    
    # Set factor levels for correct plotting order
    DAG = factor(DAG, levels = c("5DAG", "8DAG", "11DAG", "14DAG")),
    Type = ifelse(Genotype == "Col-0", "WT", "Mutant"),
    Type = factor(Type, levels = c("WT", "Mutant")),
    
    # Ensure numeric
    Hypocotyl_Height = as.numeric(Hypocotyl_Height)
  )

# Optional check
print(table(data_long$Genotype, data_long$Type))

# =========================================================
# 3. Statistical analysis (t-test for each time point)
# =========================================================
sig_labels <- data_long %>%
  group_by(DAG) %>%
  summarise(
    p_value = t.test(Hypocotyl_Height ~ Type)$p.value,
    .groups = "drop"
  ) %>%
  mutate(
    group1 = "WT",
    group2 = "Mutant",
    annotation = case_when(
      p_value <= 0.001 ~ "***",
      p_value <= 0.01 ~ "**",
      p_value <= 0.05 ~ "*",
      TRUE ~ "ns"
    )
  )

# Automatically set y-axis position for significance labels
y_max <- max(data_long$Hypocotyl_Height, na.rm = TRUE)
sig_labels$y_position <- y_max * 1.1

# =========================================================
# 4. Plot
# =========================================================
p <- ggplot(data_long, aes(x = Type, y = Hypocotyl_Height, fill = Type)) +
  geom_boxplot(outlier.shape = NA, width = 0.6) +
  facet_wrap(~DAG, nrow = 1) +
  scale_fill_manual(
    values = c("WT" = "coral", "Mutant" = "lightblue"),
    labels = c("Col-0", expression(italic("rhe1")))
  ) +
  labs(
    x = "",
    y = "Hypocotyl height (cm)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    legend.margin = margin(t = -20),
    legend.title = element_blank(),
    legend.text = element_text(size = 8),
    strip.background = element_rect(fill = "white", color = NA),
    strip.text = element_text(size = 8),
    axis.text.x = element_blank(),
    axis.text.y = element_text(size = 8),
    axis.title.y = element_text(size = 8)
  ) +
  geom_signif(
    data = sig_labels,
    aes(
      xmin = group1,
      xmax = group2,
      annotations = annotation,
      y_position = y_position
    ),
    manual = TRUE,
    inherit.aes = FALSE,
    tip_length = 0.01,
    textsize = 4
  )

# Display plot
print(p)

# =========================================================
# 5. Save figure (output folder recommended)
# =========================================================
ggsave(
  filename = "results/Hypocotyl_Height_Boxplot.pdf",
  plot = p,
  width = 4,
  height = 3
)
#rna_stability_timecourse_plot.R

############################################################
# Title: RNA stability analysis under heat stress (HS vs NS)
# Description:
# This script processes time-course expression data and 
# generates a line plot with error bars (mean ± SE) 
# comparing HS and NS conditions.
#
# IMPORTANT:
# The input data used in this script must be pre-processed 
# to represent relative expression levels.
#
# Specifically, raw expression values (e.g., Ct values from qRT-PCR) 
# should be normalized prior to analysis, for example:
# - Using ΔCt or ΔΔCt methods
# - Normalizing to an internal reference gene
# - Scaling relative to the 0 h time point (set as 1)
#
# This script does NOT perform normalization or relative expression calculation.
# It assumes that all values in the input file are already normalized 
# and comparable across samples.

############################################################

# ================================
# 1. Clear environment
# ================================
rm(list = ls())

# ================================
# 2. Load required libraries
# ================================
# Install if needed:
# install.packages(c("readxl", "tidyverse"))

library(readxl)
library(tidyverse)

# ================================
# 3. Set working directory
# ================================
# Option 1: manual input
path <- readline(prompt = "Enter working directory path: ")
setwd(path)

# Option 2 (alternative):
# setwd(dirname(file.choose()))

cat("Current working directory:", getwd(), "\n")

# ================================
# 4. Read input data
# ================================
file_path <- "AT5G4340RNAstability.xlsx"

data <- read_excel(file_path, sheet = "Sheet1", col_names = TRUE)

# Preview data
head(data)

# ================================
# 5. Convert to long format
# ================================
data_long <- data %>%
  pivot_longer(cols = everything(),
               names_to = "Sample",
               values_to = "Value") %>%
  mutate(
    Condition = str_extract(Sample, "HS|NS"),       # Extract condition
    Time = as.numeric(str_extract(Sample, "\\d+"))  # Extract time (numeric)
  )

# Check transformed data
head(data_long)

# ================================
# 6. Summarize data (mean ± SE)
# ================================
data_summary <- data_long %>%
  mutate(Time = factor(Time,
                       levels = c(0, 1, 3, 6),
                       ordered = TRUE)) %>%
  group_by(Condition, Time) %>%
  summarise(
    Mean = mean(Value, na.rm = TRUE),
    SE = sd(Value, na.rm = TRUE) / sqrt(n()),
    .groups = 'drop'
  )

# ================================
# 7. Plot time-course expression
# ================================
p <- ggplot(data_summary,
            aes(x = Time, y = Mean,
                color = Condition,
                group = Condition)) +
  
  # Points
  geom_point(size = 3) +
  
  # Lines
  geom_line(linetype = "dashed", linewidth = 1.2) +
  
  # Error bars
  geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE),
                width = 0.2,
                linewidth = 0.6) +
  
  # Labels
  labs(
    x = "Time (h)",
    y = "Relative mRNA level"
  ) +
  
  # Theme
  theme_minimal(base_size = 14) +
  theme(
    axis.title = element_text(size = 16, face = "bold"),
    axis.text = element_text(color = "black"),
    legend.title = element_text(face = "italic"),
    legend.position = "right"
  )

# ================================
# 8. Save figure
# ================================
ggsave("RNA_stability_HS_NS.pdf",
       p, width = 6, height = 4)


############################################################
# End of script
############################################################
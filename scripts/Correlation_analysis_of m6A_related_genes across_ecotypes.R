############################################################
# Title: Correlation analysis of m6A-related genes across ecotypes
# Description: 
# This script calculates the average expression of m6A-related genes 
# across different Arabidopsis ecotypes and generates a correlation matrix plot.

############################################################

# ================================
# 1. Clear environment
# ================================
rm(list = ls())

# ================================
# 2. Set working directory
# ================================

setwd("")

# Option 2 (alternative): interactive file selection
# setwd(dirname(file.choose()))

cat("Current working directory:", getwd(), "\n")

# ================================
# 3. Load required libraries
# ================================
# Install packages if needed:
# install.packages(c("readxl", "corrplot", "tidyverse"))

library(readxl)
library(corrplot)
library(tidyverse)

# ================================
# 4. Read input data
# ================================
file_path <- "data/m6A-related genes across ecotypes.xlsx"
data <- read_excel(file_path, sheet = "S2")

# Preview data
head(data)

# ================================
# 5. Calculate mean expression per ecotype
# ================================
# Define ecotypes
ecotypes <- c("Col_0", "Altal_5", "ICE_73", "Kas_2", "Kondara", "Se_0", "Zal_1")

# Create a new data frame to store averaged values
averaged_data <- data.frame(gene = data$gene)

# Loop through ecotypes and calculate row means
for (ecotype in ecotypes) {
  cols <- grep(paste0(ecotype, "_"), names(data))
  averaged_data[[ecotype]] <- rowMeans(data[, cols], na.rm = TRUE)
}

# Check results
head(averaged_data)

# ================================
# 6. Transpose data for correlation analysis
# ================================
transposed_data <- t(averaged_data)

# Convert to data frame
transposed_data_df <- as.data.frame(transposed_data)

# Set column names using first row (gene names)
colnames(transposed_data_df) <- transposed_data_df[1, ]
transposed_data_df <- transposed_data_df[-1, ]

# Remove whitespace
transposed_data_df <- as.data.frame(
  lapply(transposed_data_df, function(x) trimws(x))
)

# Convert all columns to numeric
transposed_data_df[] <- lapply(transposed_data_df, as.numeric)

# Check structure
str(transposed_data_df)

# ================================
# 7. Compute correlation matrix
# ================================
correlation_matrix <- cor(transposed_data_df, use = "complete.obs")

# Print matrix
print(correlation_matrix)

# ================================
# 8. Plot correlation matrix
# ================================
pdf(file = "M6A_correlation_matrix.pdf", width = 8, height = 8)

corrplot(
  correlation_matrix,
  method = "circle",                         # visualization method
  type = "full",                             # full matrix
  col = colorRampPalette(c("blue", "white", "red"))(200),
  tl.cex = 1.2,                              # label size
  tl.col = "black",                          # label color
  number.cex = 0.7,                          # correlation number size
  addCoef.col = "black",                     # show correlation values
  number.digits = 2,                         # decimal places
  cl.cex = 1.2,                              # color legend size
  order = "hclust",                          # hierarchical clustering
  mar = c(0.5, 0.5, 0.5, 0.5)
)

dev.off()


############################################################
# End of script
############################################################
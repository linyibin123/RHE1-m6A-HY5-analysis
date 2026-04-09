############################################################
# Title: Three-way ANOVA and visualization of hypocotyl cell length
# Description:
# This script performs three-way ANOVA (Genotype × Time × Treatment),
# followed by post hoc multiple comparisons using emmeans.
# It generates publication-quality boxplots with significance letters.

############################################################

# ================================
# 1. Clear environment
# ================================
rm(list = ls())

# ================================
# 2. Load required libraries
# ================================
# Install if needed:
# install.packages(c("readxl", "tidyverse", "car", "emmeans", "multcomp", "multcompView"))

library(readxl)
library(tidyverse)
library(car)
library(emmeans)
library(multcomp)
library(multcompView)
library(ggplot2)

# ================================
# 3. Set working directory
# ================================
# Modify to your project path
setwd("")

# ================================
# 4. Read input data
# ================================
data <- read_excel("hypocotyl.xlsx", sheet = "Sheet3")

# ================================
# 5. Convert to long format
# ================================
data_long <- data %>%
  pivot_longer(cols = everything(),
               names_to = "Group",
               values_to = "Value") %>%
  separate(Group, into = c("Genotype", "Time", "Treatment"), sep = "_")

# ================================
# 6. Factor settings
# ================================
data_long$Genotype <- factor(data_long$Genotype, levels = c("Col-0", "rhe1"))

data_long$Time <- factor(data_long$Time,
                         levels = c("5", "7", "9"),
                         labels = c("Day 5", "Day 7", "Day 9"))

data_long$Treatment <- factor(data_long$Treatment,
                              levels = c("U", "M", "L"))

# ================================
# 7. Three-way ANOVA
# ================================
model <- lm(Value ~ Genotype * Time * Treatment, data = data_long)

anova_res <- Anova(model, type = 3)
print(anova_res)

# ================================
# 8. Post hoc test (emmeans + Tukey)
# ================================
emm <- emmeans(model, ~ Genotype * Treatment | Time)

cld_res <- cld(emm,
               Letters = letters,
               adjust = "tukey") %>%
  as.data.frame()

# Remove spaces in letter grouping
cld_res$.group <- gsub(" ", "", cld_res$.group)

# ================================
# 9. Calculate label positions
# ================================
y_pos <- data_long %>%
  group_by(Time, Genotype, Treatment) %>%
  summarise(y = max(Value) * 1.1, .groups = "drop")

plot_data <- left_join(cld_res, y_pos,
                       by = c("Time", "Genotype", "Treatment"))

# ================================
# 10. Background panel data
# ================================
day_bg <- data.frame(
  Time = factor(c("Day 5", "Day 7", "Day 9"),
                levels = c("Day 5", "Day 7", "Day 9")),
  ymin = 0,
  ymax = max(data_long$Value) * 1.15
)

# ================================
# 11. Plotting
# ================================
# Define labels (italic for mutant)
genotype_labels <- c(
  "Col-0" = "Col-0",
  "rhe1"  = expression(italic("rhe1"))
)

p <- ggplot() +
  # Background shading
  geom_rect(data = day_bg,
            aes(xmin = -Inf, xmax = Inf, ymin = ymin, ymax = ymax),
            fill = "grey90",
            inherit.aes = FALSE) +
  
  # Boxplot
  geom_boxplot(data = data_long,
               aes(x = Treatment, y = Value, fill = Genotype),
               position = position_dodge(0.8),
               width = 0.7,
               outlier.shape = NA) +
  
  # Jitter points
  geom_jitter(data = data_long,
              aes(x = Treatment, y = Value, color = Genotype),
              position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.8),
              size = 1, alpha = 0.6) +
  
  # Mean points
  stat_summary(data = data_long,
               aes(x = Treatment, y = Value, group = Genotype),
               fun = mean,
               geom = "point",
               position = position_dodge(0.8),
               shape = 23, size = 2.5, fill = "white") +
  
  # Significance letters
  geom_text(data = plot_data,
            aes(x = Treatment, y = y, label = .group, group = Genotype),
            position = position_dodge(0.8),
            vjust = -0.3,
            size = 4) +
  
  # Flip coordinates for vertical layout
  coord_flip() +
  
  # Facet by time
  facet_grid(Time ~ ., scales = "free_y") +
  
  # Theme
  theme_classic(base_size = 14) +
  labs(x = "Upper / Middle / Lower hypocotyl regions",
       y = "Hypocotyl cell length (µm)") +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold", size = 12),
        axis.text = element_text(color = "black"),
        axis.title = element_text(face = "bold"),
        legend.position = "top",
        panel.spacing = unit(0.5, "cm")) +
  
  # Colors
  scale_fill_manual(values = c("Col-0" = "#56B4E9", "rhe1" = "#E69F00"),
                    labels = genotype_labels) +
  
  scale_color_manual(values = c("Col-0" = "#56B4E9", "rhe1" = "#E69F00"),
                     labels = genotype_labels)

# ================================
# 12. Save figures
# ================================
ggsave("Figure_SX_Hypocotyl_boxplot.pdf", p, width = 4, height = 8)

ggsave("Figure_SX_Hypocotyl_boxplot.tiff",
       p, width = 4, height = 8,
       dpi = 300, compression = "lzw")

# ================================
# 13. Save results tables
# ================================
write.csv(as.data.frame(anova_res),
          "Table_SX_ANOVA_results.csv",
          row.names = TRUE)

write.csv(as.data.frame(emm),
          "Table_SX_emmeans_results.csv",
          row.names = FALSE)

write.csv(cld_res,
          "Table_SX_emmeans_letters.csv",
          row.names = FALSE)

write.csv(y_pos,
          "Table_SX_label_positions.csv",
          row.names = FALSE)

############################################################
# End of script
############################################################
# RHE1 Functional Analysis

This repository contains scripts and data supporting the functional analysis of **RHE1** in *Arabidopsis thaliana*.  
It includes data processing, statistical analyses, and figure generation used in the manuscript.

---

## Directory structure

- **data/**  
  Raw input datasets (e.g., Excel files containing phenotypic or sequencing data)

- **scripts/**  
  R scripts for data processing, statistical analysis, and visualization

- **results/**  
  Output figures and tables generated from the scripts

---

## Scripts

- **correlation_m6A_ecotypes.R**  
  Performs correlation analysis of m⁶A-related gene expression across different ecotypes.

- **hypocotyl_three_way_anova.R**  
  Conducts three-way ANOVA to evaluate the effects of genotype, treatment, and time on hypocotyl cell length, followed by visualization.

- **rna_stability_timecourse_plot.R**  
  Analyzes RNA stability dynamics under heat stress using time-course data and generates corresponding plots.

- **hypocotyl_plot.R**  
  Generates boxplots of hypocotyl height at different developmental stages (DAG) and performs statistical comparisons (t-test) between wild type (Col-0) and *rhe1* mutant.

---

## Requirements

- **R (>= 4.0)**

- Required R packages:
  - tidyverse
  - readxl
  - ggplot2
  - car
  - emmeans
  - corrplot
  - ggsignif

---

## Usage

1. Place all input datasets in the `data/` directory.
2. Run scripts from the `scripts/` directory.
3. Output figures and tables will be saved in the `results/` directory.

All scripts are designed to be run independently.

---

## Reproducibility Notes

- File paths are defined using relative directories to ensure portability across systems.
- Input data should be pre-processed prior to analysis (e.g., normalized expression values).
- Statistical analyses follow standard practices (e.g., ANOVA, t-test) as described in the manuscript.

---

## Citation

If you use this repository or code, please cite the associated manuscript.

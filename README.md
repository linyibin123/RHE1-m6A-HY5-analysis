# RHE1 Functional Analysis

This repository contains scripts and data used for the analysis of RHE1-related experiments in Arabidopsis thaliana.

## Directory structure

- data/
  - Raw input datasets (Excel files)

- scripts/
  - R scripts for data processing, statistical analysis, and visualization

- results/
  - Output figures and tables generated from scripts

## Scripts

- correlation_m6A_ecotypes.R  
  Correlation analysis of m6A-related genes across ecotypes

- hypocotyl_three_way_anova.R  
  Three-way ANOVA and visualization of hypocotyl cell length

- rna_stability_timecourse_plot.R  
  Time-course analysis of RNA stability under heat stress

## Requirements

- R (>= 4.0)
- Packages:
  - tidyverse
  - readxl
  - ggplot2
  - car
  - emmeans
  - corrplot

## Notes

- Input data should be pre-processed (e.g., normalized expression values)
- All scripts are independent and can be run separately
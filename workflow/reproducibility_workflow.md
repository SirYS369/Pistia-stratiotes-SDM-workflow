# Reproducibility workflow

This document describes the workflow used to support the species distribution modelling analyses in the manuscript.

## 1. Occurrence records

Occurrence records of *Pistia stratiotes* were compiled from GBIF, CVH/NSII, PPBC, and peer-reviewed literature with explicit locality information.

The final modelling occurrence file is:

`data/Supplementary_Dataset_S1_occurrence_records.csv`

The final dataset contains 468 records: 408 GBIF records, 35 CVH/NSII records accessed through GBIF-mediated metadata, 19 PPBC records, and 6 literature-derived records.

The GBIF-mediated records are documented in:

`data/Supplementary_Dataset_S2_GBIF_CVHNSII_traceable_records.csv`

The 408 GBIF records in Supplementary Dataset S1 match the 408 GBIF records in Supplementary Dataset S2.

Quality-control steps:

1. Records lacking usable coordinates were removed.
2. Records with clearly invalid coordinates or inconsistent locality information were excluded.
3. GBIF records were screened as georeferenced presence records and checked using available GBIF-mediated metadata.
4. CVH/NSII, PPBC, and literature records were retained only after manual checking of taxonomic identity and locality consistency.
5. The GBIF base records were spatially filtered using a 2.5-minute grid to reduce local sampling redundancy.
6. Curated supplementary records from CVH/NSII, PPBC, and literature were retained to document additional source coverage where appropriate.

## 2. Environmental variables

The manuscript used bioclimatic, topographic, and hydrological variables. Climatic variables were obtained from public climate datasets described in the manuscript. Hydrological variables were interpolated from monitoring-station data as described in the Materials and methods.

Variable screening was based on correlation analysis and ecological relevance. The correlation heatmap retained for reporting is:

`outputs/correlation_heatmap_pretty.png`

## 3. MaxEnt model settings

MaxEnt was used for the main habitat suitability analysis.

Documented settings:

- Software: MaxEnt 3.4.4
- Occurrence data: final 468-record dataset
- Background points: 10,000 background points generated within the study-area mask
- Candidate tuning: 48 combinations of regularization multiplier and feature class settings
- Regularization multiplier values: 0.5 to 4.0 at 0.5 intervals
- Feature class settings: L, LQ, H, LQH, LQHP, and LQHPT
- Model-selection criterion: AICc
- Final parameter setting: RM = 2, FC = LQHPT
- Replication: bootstrap replication
- Replicate runs: 10
- Training/testing split: 75% training and 25% testing
- Maximum iterations: 5000
- Final output: average of 10 replicate suitability outputs

## 4. Suitability classification and area calculation

The continuous MaxEnt suitability output was classified into suitability categories using the natural breaks method. The manuscript reports the resulting suitability thresholds and corresponding habitat areas.

Area calculation was conducted after converting classified raster outputs to area summaries in GIS. The key requirement is that the raster and study-area mask must use a consistent spatial reference and cell size before area calculation.

## 5. Centroid-shift analysis

Centroid shifts under future climate scenarios were calculated using SDMtoolbox in ArcGIS. The workflow was:

1. Convert each MaxEnt suitability map to suitable/unsuitable habitat according to the selected threshold.
2. Use SDMtoolbox `Centroid Changes` to calculate current and future centroids.
3. Calculate centroid movement direction and distance across climate scenarios.
4. Interpret centroid displacement as a summary of directional range-shift tendency, not as direct dispersal distance.

## 6. Multi-algorithm comparison

The supplementary multi-algorithm comparison was conducted using:

`scripts/01_biomod2_multi_algorithm_comparison.R`

The output files are:

- `outputs/Supplementary_Table_S4_model_performance_comparison.xlsx`
- `outputs/Supplementary_Fig_S1_model_performance_comparison.png`

This analysis was added to evaluate whether MaxEnt-family models performed consistently relative to other algorithms.

## 7. PCA-env niche overlap analysis

The PCA-env niche overlap analysis was conducted using:

`scripts/02_pca_env_niche_overlap_analysis.R`

The output files are:

- `outputs/Fig11_climatic_niche_overlap.svg`
- `outputs/Fig11_climatic_niche_overlap.pdf`
- `outputs/Supplementary_Table_S3_niche_overlap_metrics.csv`

The analysis compares current and future climatic niche spaces within the invaded range in China.

## 8. Notes on full reproducibility

The R-based supplementary analyses are provided as scripts. The MaxEnt, ArcGIS, and SDMtoolbox steps include GUI-based procedures; therefore, this repository provides a detailed workflow rather than a single fully automated script for those components.

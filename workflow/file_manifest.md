# File manifest

## Root files

| File | Description |
|---|---|
| `README.md` | Overview of the repository. |
| `LICENSE.md` | Licence and third-party data-use notes. |
| `CITATION.cff` | Citation metadata for GitHub and Zenodo. |
| `.zenodo.json` | Zenodo metadata template. |

## data

| File | Description |
|---|---|
| `Supplementary_Dataset_S1_occurrence_records.xlsx` | Final 468-record occurrence dataset provided by the author. Use `Sheet2`. |
| `Supplementary_Dataset_S1_occurrence_records.csv` | CSV export of `Sheet2` from Supplementary Dataset S1. |
| `Supplementary_Dataset_S2_GBIF_CVHNSII_traceable_records.csv` | Traceability table for 408 GBIF records and 35 CVH/NSII records. |
| `GBIF_408_occurrence_keys_for_redownload.csv` | GBIF occurrence keys for the 408 GBIF records. |
| `GBIF_download_key_used.txt` | GBIF download key identified from available source files and terminology note. |
| `occurrence_dataset_summary.json` | Machine-readable summary of occurrence record counts and source groups. |

## scripts

| File | Description |
|---|---|
| `01_biomod2_multi_algorithm_comparison.R` | R script for supplementary multi-algorithm model comparison. |
| `02_pca_env_niche_overlap_analysis.R` | R script for PCA-env niche overlap analysis. |

## outputs

| File | Description |
|---|---|
| `correlation_heatmap_pretty.png` | Variable-correlation heatmap used during variable screening/reporting. |
| `Supplementary_Fig_S1_model_performance_comparison.png` | Supplementary model-performance comparison figure. |
| `Supplementary_Table_S4_model_performance_comparison.xlsx` | Supplementary model-performance comparison table. |
| `Fig11_climatic_niche_overlap.svg` | Vector version of climatic niche overlap figure. |
| `Fig11_climatic_niche_overlap.pdf` | PDF version of climatic niche overlap figure. |
| `Supplementary_Table_S3_niche_overlap_metrics.csv` | Niche overlap metrics table. |

## workflow

| File | Description |
|---|---|
| `reproducibility_workflow.md` | Step-by-step workflow for occurrence processing, MaxEnt, GIS, biomod2, and PCA-env analyses. |
| `data_dictionary.md` | Column definitions and missing-value notes. |
| `file_manifest.md` | This file. |

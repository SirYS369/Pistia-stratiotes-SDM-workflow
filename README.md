# Pistia stratiotes SDM open data and workflow package

This repository contains the occurrence records, traceability tables, scripts, selected outputs, and workflow documentation supporting the manuscript on the potential suitable habitat of *Pistia stratiotes* in China.

## Core contents

- `data/Supplementary_Dataset_S1_occurrence_records.xlsx`: final occurrence dataset used for manuscript revision. The usable table is `Sheet2`, containing 468 records.
- `data/Supplementary_Dataset_S1_occurrence_records.csv`: CSV export of `Sheet2` from the same file.
- `data/Supplementary_Dataset_S2_GBIF_CVHNSII_traceable_records.csv`: traceability table for 443 GBIF-mediated records, including 408 GBIF records and 35 CVH/NSII records accessed through GBIF-mediated metadata.
- `data/GBIF_408_occurrence_keys_for_redownload.csv`: GBIF occurrence keys for the 408 GBIF records in the final dataset.
- `data/GBIF_download_key_used.txt`: GBIF download key identified from the available source files.
- `scripts/01_biomod2_multi_algorithm_comparison.R`: supplementary multi-algorithm SDM comparison.
- `scripts/02_pca_env_niche_overlap_analysis.R`: PCA-env niche overlap analysis.
- `workflow/reproducibility_workflow.md`: step-by-step description of non-R and R workflow components.
- `workflow/data_dictionary.md`: column definitions for data files.
- `workflow/file_manifest.md`: file-by-file description.

## Occurrence data summary

The final occurrence dataset contains 468 records:

- GBIF: 408 records
- CVH/NSII via GBIF: 35 records
- PPBC: 19 records
- Literature: 6 records

The 408 GBIF records in `Supplementary_Dataset_S1_occurrence_records.csv` match the 408 GBIF rows in `Supplementary_Dataset_S2_GBIF_CVHNSII_traceable_records.csv`.

Important terminology note: the `gbif_key` column in Supplementary Dataset S2 is the GBIF occurrence key, also known as the GBIF occurrence ID or `gbifID`, for each individual record. It is not the GBIF download job key. The GBIF download key identified from the available files is recorded separately in `data/GBIF_download_key_used.txt`.

## Software and workflow

This package includes R scripts for the analyses that were scripted during revision. Some manuscript steps were conducted in GUI-based software, including MaxEnt, ArcGIS, and SDMtoolbox. These are documented in `workflow/reproducibility_workflow.md` with software versions, parameter settings, filtering rules, and output interpretation.

## Recommended citation after Zenodo archiving

After uploading this repository to GitHub and creating a Zenodo archive, cite the Zenodo DOI in the manuscript Data Availability statement and response letter. Replace all placeholder repository URLs and DOI fields with the final Zenodo DOI assigned to your release.

## Licence

Code files are released under the MIT-style terms described in `LICENSE.md`. Reused biodiversity records and environmental data remain subject to the licences and terms of their original providers, including GBIF, CVH/NSII, PPBC, WorldClim, and other public data sources cited in the manuscript.

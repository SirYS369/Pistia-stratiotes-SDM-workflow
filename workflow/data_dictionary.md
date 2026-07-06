# Data dictionary

## Supplementary_Dataset_S1_occurrence_records.csv

This file is the CSV export of `Sheet2` from `Supplementary_Dataset_S1_occurrence_records.xlsx`.

| Column | Meaning |
|---|---|
| `species` | Species name used in the modelling input. |
| `x` | Longitude in decimal degrees. |
| `y` | Latitude in decimal degrees. |
| `source` | Occurrence data source. Values include `GBIF`, `CVH/NSII via GBIF`, `PPBC`, and `Literature`. |
| `time` | Observation or collection date where available. For some curated records, only a year or source identifier may be available. |

## Supplementary_Dataset_S2_GBIF_CVHNSII_traceable_records.csv

This table provides traceability for the GBIF-mediated occurrence records used to support the final dataset.

| Column | Meaning |
|---|---|
| `species` | Species name used in the modelling input. |
| `x` | Longitude in decimal degrees. |
| `y` | Latitude in decimal degrees. |
| `source` | Source group, either `GBIF` or `CVH/NSII via GBIF`. |
| `time` | Observation, collection, or record year where available. |
| `gbif_key` | GBIF occurrence key (`gbifID`) for the individual record. This is not the GBIF download job key. |
| `datasetKey` | GBIF dataset key. |
| `datasetTitle` | Dataset title when available from GBIF metadata. |
| `country` | Country or region code in the GBIF-mediated record. |
| `province` | Province or administrative region where available. |
| `locality` | Locality text where available. |
| `basisOfRecord` | GBIF basis of record. |
| `institutionCode` | Institution code where available. |
| `collectionCode` | Collection code where available. |
| `catalogNumber` | Catalog number where available. |
| `recordedBy` | Collector or observer where available. |
| `identifiedBy` | Identifier where available. |
| `references` | Source URL or record reference where available. |
| `grid_2p5min_x` | 2.5-minute grid index used during spatial filtering. |
| `grid_2p5min_y` | 2.5-minute grid index used during spatial filtering. |
| `grid_duplicate_status` | Whether the record is unique or supplementary within the filtering workflow. |
| `source_group` | More detailed source grouping. |

## GBIF_408_occurrence_keys_for_redownload.csv

This file lists the GBIF occurrence keys and associated metadata for the 408 GBIF records in the final dataset. It can be used to re-check or re-download the selected GBIF occurrence records.

## Missing values

Blank cells indicate that the corresponding metadata were not available in the source record or were not retained in the modelling table.

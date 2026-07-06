# biomod2 current-distribution workflow
# Tested with biomod2 4.3.x. In this version, the old "ROC" metric is named
# "AUCroc".

knitr::opts_chunk$set(
  echo = TRUE,
  dpi = 400,
  warning = FALSE,
  message = FALSE,
  fig.align = "center",
  comment = "#>"
)

par(
  family = "Times New Roman",
  bg = "white",
  mar = c(4, 4, 2, 2),
  mgp = c(2, 1, 0),
  cex.main = 1.2,
  cex.axis = 0.9,
  cex.lab = 1.1
)

required_packages <- c(
  "knitr", "biomod2", "xgboost", "tidyverse", "tidyterra", "terra",
  "ggplot2", "ggtext", "R.utils", "mda", "gam", "earth", "maxnet"
)
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0) {
  stop(
    "Install these packages before running the script: ",
    paste(missing_packages, collapse = ", ")
  )
}

library(biomod2)
library(xgboost)
library(tidyverse)
library(tidyterra)
library(terra)
library(ggplot2)

# Input data paths.
species_file <- "G:/species.csv"
environment_dir <- "G:/now"

# All model outputs are written to the Desktop.
desktop_dir <- file.path(Sys.getenv("USERPROFILE"), "Desktop")
output_dir <- file.path(desktop_dir, "biomod_current_results")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
setwd(output_dir)

# Models to run. The removed tree-ensemble variants are omitted here.
selected_models <- c(
  "ANN", "CTA", "FDA", "GAM", "GBM", "GLM", "MARS",
  "MAXNET", "SRE", "XGBOOST"
)

# Read species occurrence points.
species <- read.csv(species_file, check.names = FALSE)
required_species_columns <- c("species", "lon", "lat")
missing_species_columns <- setdiff(required_species_columns, names(species))
if (length(missing_species_columns) > 0) {
  stop(
    "species.csv is missing these columns: ",
    paste(missing_species_columns, collapse = ", ")
  )
}

species_name <- unique(na.omit(species$species))[1]
species_name <- gsub("[^A-Za-z0-9_]+", "_", species_name)
if (is.na(species_name) || !nzchar(species_name)) {
  species_name <- "species_model"
}

# BIOMOD_FormatingData expects a numeric response vector for presence data.
species$Species <- 1L

# Read current environmental predictors as a SpatRaster. biomod2 4.3.x expects
# terra objects here.
env_files <- list.files(environment_dir, pattern = "\\.asc$", full.names = TRUE)
if (length(env_files) == 0) {
  stop("No .asc environmental files were found in: ", environment_dir)
}
env <- terra::rast(env_files)

# Quick visual check. This is optional and should not stop the model workflow.
try({
  env_plot <- ggplot() +
    geom_spatraster(data = env) +
    geom_point(data = species, aes(x = lon, y = lat), size = 1, color = "pink") +
    facet_wrap(~lyr) +
    scale_fill_whitebox_c(palette = "muted", na.value = "white") +
    theme_light() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))

  ggsave(
    filename = file.path(output_dir, "species_environment_check.png"),
    plot = env_plot,
    width = 12,
    height = 8,
    dpi = 300
  )
}, silent = TRUE)

# Create pseudo-absence datasets.
ps_abs <- BIOMOD_FormatingData(
  expl.var = env,
  resp.var = species$Species,
  resp.xy = species[, c("lon", "lat")],
  resp.name = species_name,
  PA.nb.rep = 3,
  PA.nb.absences = 797,
  PA.strategy = "random"
)

# Export pseudo-absence coordinates.
pseudo_absences <- do.call(
  rbind,
  lapply(names(ps_abs@PA.table), function(pa_name) {
    coords <- ps_abs@coord[which(ps_abs@PA.table[[pa_name]]), , drop = FALSE]
    data.frame(PA = pa_name, coords, row.names = NULL)
  })
)
write.csv(
  pseudo_absences,
  file.path(output_dir, "pseudo_absences.csv"),
  row.names = FALSE
)

save(ps_abs, file = file.path(output_dir, "pseudo_absences.RData"))

try({
  png(file.path(output_dir, "pseudo_absences.png"), width = 2400, height = 1800, res = 300)
  plot(ps_abs)
  dev.off()
}, silent = TRUE)

# Build single models.
model_one <- BIOMOD_Modeling(
  bm.format = ps_abs,
  modeling.id = "AllModels",
  models = selected_models,
  CV.strategy = "random",
  CV.nb.rep = 10,
  CV.perc = 0.7,
  metric.eval = c("KAPPA", "TSS", "AUCroc"),
  weights = NULL,
  prevalence = 0.5,
  var.import = 3
)

# Export single-model evaluation scores.
scores_one <- get_evaluations(model_one) |>
  as.data.frame.array()
write.csv(
  scores_one,
  file.path(output_dir, "scores_one_single_models.csv"),
  row.names = FALSE
)

# Export single-model variable importance.
var_imp_one <- get_variables_importance(model_one) |>
  as.data.frame.array()
write.csv(
  var_imp_one,
  file.path(output_dir, "variable_importance_single_models.csv"),
  row.names = FALSE
)

# Export data behind the AUCroc/TSS evaluation plot.
aucroc_tss <- bm_PlotEvalMean(
  bm.out = model_one,
  dataset = "calibration",
  metric.eval = c("AUCroc", "TSS"),
  xlim = c(0, 1),
  ylim = c(0, 1)
)
write.csv(
  aucroc_tss$tab,
  file.path(output_dir, "AUCroc_TSS.csv"),
  row.names = FALSE
)

# Additional evaluation and variable-importance plots.
eval_boxplot_by_algorithm <- bm_PlotEvalBoxplot(
  bm.out = model_one,
  dataset = "calibration",
  group.by = c("algo", "algo")
)
eval_boxplot_by_run <- bm_PlotEvalBoxplot(
  bm.out = model_one,
  dataset = "calibration",
  group.by = c("algo", "run")
)
varimp_by_variable_algorithm <- bm_PlotVarImpBoxplot(
  bm.out = model_one,
  group.by = c("expl.var", "algo", "algo")
)
varimp_by_variable_run <- bm_PlotVarImpBoxplot(
  bm.out = model_one,
  group.by = c("expl.var", "algo", "run")
)

# Export response-curve data for single models.
response_single <- bm_PlotResponseCurves(
  bm.out = model_one,
  models.chosen = "all",
  new.env = get_formal_data(model_one, "expl.var"),
  show.variables = get_formal_data(model_one, "expl.var.names"),
  data_species = get_formal_data(model_one, "resp.var"),
  fixed.var = "median",
  do.bivariate = FALSE,
  do.plot = TRUE,
  legend = TRUE,
  do.progress = TRUE
)
write.csv(
  response_single$tab,
  file.path(output_dir, "response_curves_single_models.csv"),
  row.names = FALSE
)

# Build ensemble models.
model_EM <- BIOMOD_EnsembleModeling(
  bm.mod = model_one,
  models.chosen = "all",
  em.by = "all",
  em.algo = c("EMmean", "EMcv", "EMci", "EMmedian", "EMca", "EMwmean"),
  metric.select = c("TSS", "AUCroc"),
  metric.select.thresh = c(0.8, 0.9),
  metric.eval = c("TSS", "AUCroc", "KAPPA"),
  var.import = 3,
  EMci.alpha = 0.05,
  EMwmean.decay = "proportional"
)

# Export ensemble-model evaluation scores.
scores_EM <- get_evaluations(model_EM) |>
  as.data.frame.array()
write.csv(
  scores_EM,
  file.path(output_dir, "scores_ensemble_models.csv"),
  row.names = FALSE
)

# Export ensemble-model variable importance.
var_imp_EM <- get_variables_importance(model_EM) |>
  as.data.frame.array()
write.csv(
  var_imp_EM,
  file.path(output_dir, "variable_importance_ensemble_models.csv"),
  row.names = FALSE
)

# Export response-curve data for ensemble models.
response_ensemble <- bm_PlotResponseCurves(
  bm.out = model_EM,
  models.chosen = "all",
  new.env = get_formal_data(model_one, "expl.var"),
  show.variables = get_formal_data(model_one, "expl.var.names"),
  data_species = get_formal_data(model_one, "resp.var"),
  fixed.var = "median",
  do.bivariate = FALSE,
  do.plot = TRUE,
  legend = TRUE,
  do.progress = TRUE
)
write.csv(
  response_ensemble$tab,
  file.path(output_dir, "response_curves_ensemble_models.csv"),
  row.names = FALSE
)

# Project current potential habitat with single models.
current_one <- BIOMOD_Projection(
  bm.mod = model_one,
  new.env = env,
  proj.name = "current",
  output.format = ".tif",
  keep.in.memory = FALSE,
  do.stack = FALSE
)

# Project current potential habitat with ensemble models.
current_EM <- BIOMOD_EnsembleForecasting(
  bm.em = model_EM,
  proj.name = "current_EM",
  bm.proj = current_one,
  output.format = ".tif",
  keep.in.memory = FALSE,
  do.stack = FALSE
)

cat("Finished current biomod workflow.\n")
cat("Species name:", species_name, "\n")
cat("Output directory:", output_dir, "\n")

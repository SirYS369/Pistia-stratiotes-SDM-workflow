setwd("G:/ecospat")

# Load the packages required by this script
library(raster)
library(dismo)
library(ecospat)
library(ade4)

# -----------------------------
# 1. Basic paths and plotting parameters
# -----------------------------
base_dir <- "G:/ecospat"
asc_dir <- file.path(base_dir, "asc")
output_dir <- file.path(base_dir, "niche_overlap")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

env_cols <- c("bio2", "bio3", "bio7", "bio9", "bio15")
all_cols <- c("x", "y", env_cols, "predictions", "species_occ")

scenario_codes <- c("30126", "30245", "30370", "30585", "50126", "50245", "50370", "50585")
env_file_names <- c("bio_2.asc", "bio_3.asc", "bio_7.asc", "bio_9.asc", "bio_15.asc", "predictions.asc")

# Figure requirements: 7 cm x 7 cm, Times New Roman, PNG at 600 dpi.
plot_width_cm <- 7
plot_height_cm <- 7
plot_width_in <- plot_width_cm / 2.54
plot_height_in <- plot_height_cm / 2.54
plot_dpi <- 600
plot_pointsize <- 8.5
font_family <- "Times New Roman"

if (.Platform$OS.type == "windows") {
  grDevices::windowsFonts(TimesNewRoman = grDevices::windowsFont("Times New Roman"))
}

open_pdf_device <- function(file) {
  if (capabilities("cairo")) {
    grDevices::cairo_pdf(
      filename = file,
      width = plot_width_in,
      height = plot_height_in,
      pointsize = plot_pointsize,
      family = font_family
    )
  } else {
    grDevices::pdf(
      file = file,
      width = plot_width_in,
      height = plot_height_in,
      pointsize = plot_pointsize,
      family = "Times"
    )
  }
}

open_png_device <- function(file) {
  grDevices::png(
    filename = file,
    width = plot_width_cm,
    height = plot_height_cm,
    units = "cm",
    res = plot_dpi,
    type = if (capabilities("cairo")) "cairo" else "windows",
    pointsize = plot_pointsize,
    family = font_family
  )
}

save_plot_pair <- function(file_stub, plot_fun,
                           mar = c(3.3, 3.3, 2.1, 0.8),
                           cex.axis = 1.08,
                           cex.lab = 1.18,
                           cex.main = 1.08) {
  render_one <- function(ext) {
    if (ext == "pdf") {
      open_pdf_device(paste0(file_stub, ".pdf"))
    } else {
      open_png_device(paste0(file_stub, ".png"))
    }

    old_par <- graphics::par(no.readonly = TRUE)
    tryCatch(
      {
        graphics::par(
          family = font_family,
          mar = mar,
          mgp = c(2.0, 0.55, 0),
          tcl = -0.22,
          las = 1,
          cex.axis = cex.axis,
          cex.lab = cex.lab,
          cex.main = cex.main
        )
        plot_fun()
      },
      finally = {
        graphics::par(old_par)
        grDevices::dev.off()
      }
    )
  }

  render_one("pdf")
  render_one("png")
}

# -----------------------------
# 2. Read environmental data and occurrence-point data
# -----------------------------
get_env_files <- function(path) {
  files <- file.path(path, env_file_names)
  missing_files <- files[!file.exists(files)]
  if (length(missing_files) > 0) {
    stop(paste0("缺少环境或预测文件：\n", paste(missing_files, collapse = "\n")))
  }
  files
}

extract_occ_values <- function(path, occs) {
  env_files <- get_env_files(path)
  env_stack <- raster::stack(env_files)
  values <- raster::extract(env_stack, occs)
  colnames(values) <- c(env_cols, "predictions")
  values
}

set.seed(20260612)

# Extract background points
envs <- raster::stack(file.path(base_dir, "bg.asc"))
bg <- dismo::randomPoints(envs, n = 10000)
bg <- as.data.frame(bg)
write.csv(bg, file.path(base_dir, "bg.csv"), row.names = FALSE)

# Load occurrence-point data
occs <- read.csv(file.path(base_dir, "species.csv"))
occs <- as.matrix(occs[, c(2, 3)])

# Extract environmental values at current and future occurrence points
icurrent <- extract_occ_values(file.path(asc_dir, "current"), occs)
i50126 <- extract_occ_values(file.path(asc_dir, "50", "126"), occs)
i50245 <- extract_occ_values(file.path(asc_dir, "50", "245"), occs)
i50370 <- extract_occ_values(file.path(asc_dir, "50", "370"), occs)
i50585 <- extract_occ_values(file.path(asc_dir, "50", "585"), occs)
i30126 <- extract_occ_values(file.path(asc_dir, "30", "126"), occs)
i30245 <- extract_occ_values(file.path(asc_dir, "30", "245"), occs)
i30370 <- extract_occ_values(file.path(asc_dir, "30", "370"), occs)
i30585 <- extract_occ_values(file.path(asc_dir, "30", "585"), occs)

write.csv(icurrent, file.path(base_dir, "icurrent.csv"), row.names = FALSE)
write.csv(i30126, file.path(base_dir, "i30126.csv"), row.names = FALSE)
write.csv(i30245, file.path(base_dir, "i30245.csv"), row.names = FALSE)
write.csv(i30370, file.path(base_dir, "i30370.csv"), row.names = FALSE)
write.csv(i30585, file.path(base_dir, "i30585.csv"), row.names = FALSE)
write.csv(i50126, file.path(base_dir, "i50126.csv"), row.names = FALSE)
write.csv(i50245, file.path(base_dir, "i50245.csv"), row.names = FALSE)
write.csv(i50370, file.path(base_dir, "i50370.csv"), row.names = FALSE)
write.csv(i50585, file.path(base_dir, "i50585.csv"), row.names = FALSE)

ecospatcurrent <- cbind(occs, icurrent)
ecospat30126 <- cbind(occs, i30126)
ecospat30245 <- cbind(occs, i30245)
ecospat30370 <- cbind(occs, i30370)
ecospat30585 <- cbind(occs, i30585)
ecospat50126 <- cbind(occs, i50126)
ecospat50245 <- cbind(occs, i50245)
ecospat50370 <- cbind(occs, i50370)
ecospat50585 <- cbind(occs, i50585)

# -----------------------------
# 3. Read binary suitable-habitat layers
# -----------------------------
bin_file_names <- c(
  "bincurrent.asc",
  "bin30126.asc",
  "bin30245.asc",
  "bin30370.asc",
  "bin30585.asc",
  "bin50126.asc",
  "bin50245.asc",
  "bin50370.asc",
  "bin50585.asc"
)
bin_codes <- c("current", scenario_codes)
bin.files <- file.path(asc_dir, "bin", bin_file_names)

missing_bin_files <- bin.files[!file.exists(bin.files)]
if (length(missing_bin_files) > 0) {
  stop(paste0("缺少二值化适生区 ASC 文件：\n", paste(missing_bin_files, collapse = "\n")))
}

binenvs <- raster::stack(bin.files)
names(binenvs) <- bin_codes
bin_values <- as.data.frame(raster::extract(binenvs, occs))

format_ecospat_data <- function(dat, bin_col) {
  dat <- as.data.frame(dat)
  colnames(dat) <- c("x", "y", env_cols, "predictions")
  dat$species_occ <- as.numeric(bin_col)
  dat <- dat[, all_cols]
  na.omit(dat)
}

ecospatcurrent <- format_ecospat_data(ecospatcurrent, bin_values$current)
ecospat30126 <- format_ecospat_data(ecospat30126, bin_values$`30126`)
ecospat30245 <- format_ecospat_data(ecospat30245, bin_values$`30245`)
ecospat30370 <- format_ecospat_data(ecospat30370, bin_values$`30370`)
ecospat30585 <- format_ecospat_data(ecospat30585, bin_values$`30585`)
ecospat50126 <- format_ecospat_data(ecospat50126, bin_values$`50126`)
ecospat50245 <- format_ecospat_data(ecospat50245, bin_values$`50245`)
ecospat50370 <- format_ecospat_data(ecospat50370, bin_values$`50370`)
ecospat50585 <- format_ecospat_data(ecospat50585, bin_values$`50585`)

write.csv(ecospatcurrent, file.path(output_dir, "ecospatcurrent.csv"), row.names = FALSE)
write.csv(ecospat30126, file.path(output_dir, "ecospat30126.csv"), row.names = FALSE)
write.csv(ecospat30245, file.path(output_dir, "ecospat30245.csv"), row.names = FALSE)
write.csv(ecospat30370, file.path(output_dir, "ecospat30370.csv"), row.names = FALSE)
write.csv(ecospat30585, file.path(output_dir, "ecospat30585.csv"), row.names = FALSE)
write.csv(ecospat50126, file.path(output_dir, "ecospat50126.csv"), row.names = FALSE)
write.csv(ecospat50245, file.path(output_dir, "ecospat50245.csv"), row.names = FALSE)
write.csv(ecospat50370, file.path(output_dir, "ecospat50370.csv"), row.names = FALSE)
write.csv(ecospat50585, file.path(output_dir, "ecospat50585.csv"), row.names = FALSE)

future_list <- list(
  "30126" = ecospat30126,
  "30245" = ecospat30245,
  "30370" = ecospat30370,
  "30585" = ecospat30585,
  "50126" = ecospat50126,
  "50245" = ecospat50245,
  "50370" = ecospat50370,
  "50585" = ecospat50585
)

# -----------------------------
# 4. Parameters for niche-overlap analysis
# -----------------------------
grid_resolution <- 100
intersection_value <- 0.1
test_rep <- 1000

# On Windows, multicore ecospat tests may trigger 'NULL value passed as symbol address'; using a single core is more stable.
ncores_use <- 1

run_overlap <- function(future_data, scenario_code) {
  message("开始分析 current vs ", scenario_code)

  current_env <- ecospatcurrent[, env_cols]
  future_env <- future_data[, env_cols]
  current_sp <- ecospatcurrent[ecospatcurrent$species_occ == 1, env_cols]
  future_sp <- future_data[future_data$species_occ == 1, env_cols]

  if (nrow(current_sp) < 5) {
    stop("current 中 species_occ == 1 的点太少，无法稳定计算生态位密度。")
  }
  if (nrow(future_sp) < 5) {
    stop(paste0(scenario_code, " 中 species_occ == 1 的点太少，无法稳定计算生态位密度。"))
  }

  # PCA-env: build a two-dimensional environmental space using both current and future environmental values.
  pca.env <- ade4::dudi.pca(
    rbind(current_env, future_env),
    center = TRUE,
    scale = TRUE,
    scannf = FALSE,
    nf = 2
  )

  save_plot_pair(
    file.path(output_dir, paste0("PCA_", scenario_code)),
    function() {
      ecospat.plot.contrib(contrib = pca.env$co, eigen = pca.env$eig)
    }
  )

  scores.globclim <- pca.env$li[, 1:2]
  scores.clim.current <- ade4::suprow(pca.env, current_env)$li[, 1:2]
  scores.clim.future <- ade4::suprow(pca.env, future_env)$li[, 1:2]
  scores.sp.current <- ade4::suprow(pca.env, current_sp)$li[, 1:2]
  scores.sp.future <- ade4::suprow(pca.env, future_sp)$li[, 1:2]

  # Build suitable-habitat density grids for the current and future scenarios in PCA environmental space.
  grid.current <- ecospat.grid.clim.dyn(
    glob = scores.globclim,
    glob1 = scores.clim.current,
    sp = scores.sp.current,
    R = grid_resolution,
    th.sp = 0
  )

  grid.future <- ecospat.grid.clim.dyn(
    glob = scores.globclim,
    glob1 = scores.clim.future,
    sp = scores.sp.future,
    R = grid_resolution,
    th.sp = 0
  )

  # Calculate Schoener's D and Hellinger-based I.
  overlap <- ecospat.niche.overlap(grid.current, grid.future, cor = TRUE)

  # Calculate niche dynamic indices: expansion, stability, and unfilling.
  niche.dyn <- ecospat.niche.dyn.index(
    grid.current,
    grid.future,
    intersection = intersection_value
  )

  dyn_index <- as.data.frame(t(niche.dyn$dynamic.index.w))
  dyn_index$scenario <- scenario_code
  dyn_index$D <- overlap$D
  dyn_index$I <- overlap$I
  dyn_index <- dyn_index[, c("scenario", "D", "I", "expansion", "stability", "unfilling")]
  write.csv(dyn_index, file.path(output_dir, paste0("niche_dynamic_index_", scenario_code, ".csv")), row.names = FALSE)

  category_quantity <- as.data.frame(t(niche.dyn$category_quantity))
  category_quantity$scenario <- scenario_code
  write.csv(category_quantity, file.path(output_dir, paste0("niche_category_quantity_", scenario_code, ".csv")), row.names = FALSE)

  # Plot niche overlap and annotate D and I values in the upper-left corner.
  save_plot_pair(
    file.path(output_dir, paste0("Niche_Overlap_", scenario_code)),
    function() {
      ecospat.plot.niche.dyn(
        grid.current,
        grid.future,
        intersection = intersection_value,
        title = paste0("Current vs ", scenario_code),
        name.axis1 = "PC1",
        name.axis2 = "PC2",
        interest = 1,
        cex.axis = 1.25,
        cex.lab = 1.35,
        cex.main = 1.18
      )
      ecospat.shift.centroids(scores.sp.current, scores.sp.future, scores.clim.current, scores.clim.future)

      usr <- graphics::par("usr")
      graphics::text(
        x = usr[1] + 0.04 * diff(usr[1:2]),
        y = usr[4] - 0.04 * diff(usr[3:4]),
        labels = sprintf("D=%.3f\nI=%.3f", overlap$D, overlap$I),
        adj = c(0, 1),
        cex = 1.18,
        font = 2,
        family = font_family,
        xpd = NA
      )
    },
    mar = c(3.8, 3.8, 2.2, 0.9),
    cex.axis = 1.25,
    cex.lab = 1.35,
    cex.main = 1.18
  )

  message("开始等效性检验 current vs ", scenario_code)
  eq.test <- ecospat.niche.equivalency.test(
    grid.current,
    grid.future,
    rep = test_rep,
    intersection = intersection_value,
    ncores = ncores_use,
    overlap.alternative = "higher",
    expansion.alternative = "lower",
    stability.alternative = "higher",
    unfilling.alternative = "lower"
  )

  save_plot_pair(
    file.path(output_dir, paste0("Equivalency_D_", scenario_code)),
    function() {
      ecospat.plot.overlap.test(eq.test, "D", "Equivalency")
    }
  )

  message("开始相似性检验 current vs ", scenario_code)
  sim.test <- ecospat.niche.similarity.test(
    grid.current,
    grid.future,
    rep = test_rep,
    ncores = ncores_use,
    overlap.alternative = "higher",
    expansion.alternative = "lower",
    stability.alternative = "higher",
    unfilling.alternative = "lower",
    intersection = intersection_value,
    rand.type = 2
  )

  save_plot_pair(
    file.path(output_dir, paste0("Similarity_D_", scenario_code)),
    function() {
      ecospat.plot.overlap.test(sim.test, "D", "Similarity")
    }
  )

  save_plot_pair(
    file.path(output_dir, paste0("Similarity_expansion_", scenario_code)),
    function() {
      ecospat.plot.overlap.test(sim.test, "expansion", "Similarity")
    }
  )

  save_plot_pair(
    file.path(output_dir, paste0("Similarity_stability_", scenario_code)),
    function() {
      ecospat.plot.overlap.test(sim.test, "stability", "Similarity")
    }
  )

  save_plot_pair(
    file.path(output_dir, paste0("Similarity_unfilling_", scenario_code)),
    function() {
      ecospat.plot.overlap.test(sim.test, "unfilling", "Similarity")
    }
  )

  # Save the main p-values from the tests.
  test_summary <- data.frame(
    scenario = scenario_code,
    equivalency_p_D = eq.test$p.D,
    equivalency_p_I = eq.test$p.I,
    equivalency_p_expansion = eq.test$p.expansion,
    equivalency_p_stability = eq.test$p.stability,
    equivalency_p_unfilling = eq.test$p.unfilling,
    similarity_p_D = sim.test$p.D,
    similarity_p_I = sim.test$p.I,
    similarity_p_expansion = sim.test$p.expansion,
    similarity_p_stability = sim.test$p.stability,
    similarity_p_unfilling = sim.test$p.unfilling
  )
  write.csv(test_summary, file.path(output_dir, paste0("niche_test_pvalues_", scenario_code, ".csv")), row.names = FALSE)

  cbind(dyn_index, test_summary[, -1])
}

# -----------------------------
# 5. Loop analysis for 2 periods and 4 scenarios
# -----------------------------
summary_list <- lapply(names(future_list), function(code) {
  run_overlap(future_list[[code]], code)
})

niche_overlap_summary <- do.call(rbind, summary_list)
write.csv(niche_overlap_summary, file.path(output_dir, "niche_overlap_summary.csv"), row.names = FALSE)

message("全部生态位重叠分析完成。结果已输出到：", output_dir)

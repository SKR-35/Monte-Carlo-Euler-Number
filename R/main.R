#!/usr/bin/env Rscript

# main.R
suppressPackageStartupMessages({
  library(optparse)
  library(ggplot2)
  library(data.table)})

source("R/sim_uniform.R")
source("R/sim_derangements.R")
source("R/plotting.R")

opt <- OptionParser(option_list = list(
  make_option("--mode", type = "character", default = "uniform",
              help = "uniform | derangements | compare"),
  make_option("--reps", type = "integer", default = 20000,
              help = "number of Monte Carlo repetitions"),
  make_option("--n", type = "integer", default = 200,
              help = "n for derangements permutations"),
  make_option("--seed", type = "integer", default = 42),
  make_option("--outdir", type = "character", default = "results"),
  make_option("--animate", type = "logical", default = TRUE,
              help = "produce GIF animation (requires gganimate+gifski)"),
  make_option("--frames", type = "integer", default = 200,
              help = "frames for GIF animations")
))

o <- parse_args(opt)
dir.create(o$outdir, showWarnings = FALSE, recursive = TRUE)

if (o$mode == "uniform") {
  res <- simulate_e_uniform(reps = o$reps, seed = o$seed)
  # Save summary & static plot
  summary <- data.frame(method = res$method, reps = res$reps,
                        estimate = res$estimate, se = res$se,
                        ci95_lo = res$ci95[1], ci95_hi = res$ci95[2])
  write.csv(summary, file.path(o$outdir, "uniform_summary.csv"), row.names = FALSE)
  p <- plot_convergence_uniform(res$k_vec)
  ggsave(file.path(o$outdir, "uniform_convergence.png"), p, width = 7, height = 5, dpi = 150)
  if (isTRUE(o$animate)) animate_convergence_uniform(res$k_vec,
      outfile = file.path(o$outdir, "uniform_convergence.gif"),
      nframes = o$frames)

} else if (o$mode == "derangements") {
  res <- simulate_e_derangements(n = o$n, reps = o$reps, seed = o$seed)
  summary <- data.frame(method = res$method, n = o$n, reps = res$reps,
                        estimate = res$estimate, se = res$se,
                        ci95_lo = res$ci95[1], ci95_hi = res$ci95[2], p_hat = res$p_hat)
  write.csv(summary, file.path(o$outdir, "derangements_summary.csv"), row.names = FALSE)
  p <- plot_convergence_derangements(res$derangements)
  ggsave(file.path(o$outdir, "derangements_convergence.png"), p, width = 7, height = 5, dpi = 150)
  if (isTRUE(o$animate)) animate_convergence_derangements(res$derangements,
      outfile = file.path(o$outdir, "derangements_convergence.gif"),
      nframes = o$frames)

} else if (o$mode == "compare") {
  u <- simulate_e_uniform(reps = o$reps, seed = o$seed)
  d <- simulate_e_derangements(n = o$n, reps = o$reps, seed = o$seed + 1L)
  df <- data.frame(
    method = c("uniform_sum", "derangements"),
    reps   = c(u$reps, d$reps),
    estimate = c(u$estimate, d$estimate),
    se       = c(u$se, d$se)
  )
  write.csv(df, file.path(o$outdir, "compare_summary.csv"), row.names = FALSE)
  message("Saved compare_summary.csv")
} else {
  stop("Unknown --mode. Use uniform | derangements | compare.")
}
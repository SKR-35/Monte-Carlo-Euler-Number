# plotting.R
suppressPackageStartupMessages({
  library(ggplot2)
  library(data.table)
})

# ---- Derangements: per-step CI via delta method ----
.derangements_curve_df <- function(der_flags) {
  t  <- seq_along(der_flags)
  x  <- cumsum(der_flags)
  p  <- x / t
  e  <- 1 / p
  e[p == 0] <- NA  # before first derangement, undefined
  se_p <- sqrt(p * pmax(0, 1 - p) / t)
  se_e <- se_p / (p^2)
  data.frame(trial = t, e_hat = e,
             lo = e - 1.96 * se_e,
             hi = e + 1.96 * se_e)
}

.y_limits_robust <- function(e_hat, e_true = exp(1), cap = 10) {
  vals <- e_hat[is.finite(e_hat)]
  if (!length(vals)) return(c(e_true - 0.6, e_true + 0.6))
  q <- stats::quantile(vals, c(0.01, 0.99), na.rm = TRUE)
  ymin <- min(q[1], e_true - 0.6)
  ymax <- min(cap, max(q[2], e_true + 0.6))
  c(ymin, ymax)
}

running_ci <- function(x) {
  t <- seq_along(x)
  m <- cumsum(x) / t
  s2 <- (cumsum(x^2) - t * m^2) / pmax(1, t - 1)     # unbiased var
  se <- sqrt(pmax(s2, 0)) / sqrt(t)
  data.frame(trial = t, mean = m, lo = m - 1.96*se, hi = m + 1.96*se)
}

plot_convergence_uniform <- function(k_vec, e_true = exp(1)) {
  df <- running_ci(k_vec)
  ggplot(df, aes(trial, mean)) +
    geom_ribbon(aes(ymin = lo, ymax = hi), alpha = 0.15) +
    geom_line(size = 0.8) +
    geom_hline(yintercept = e_true, linetype = "dashed") +
    annotate("label", x = max(df$trial)*0.9, y = e_true,
             label = "e", label.size = 0, alpha = 0.7) +
    labs(title = "Convergence of ê (Uniform-Sum)",
         subtitle = "Running mean with 95% MC CI; dashed line is e",
         x = "Trials", y = "Running mean of K (≈ e)") +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank())
}

plot_convergence_derangements <- function(der_flags, e_true = exp(1)) {
  df <- .derangements_curve_df(der_flags)
  lims <- .y_limits_robust(df$e_hat, e_true, cap = 10)  # keep spike ≤ 10
  ggplot(df, aes(trial, e_hat)) +
    geom_ribbon(aes(ymin = lo, ymax = hi), alpha = 0.15, na.rm = TRUE) +
    geom_line(size = 0.8, na.rm = TRUE) +
    geom_hline(yintercept = e_true, linetype = "dashed") +
    coord_cartesian(ylim = lims) +
    labs(title = "Convergence of ê (Derangements)",
         subtitle = "Per-step 95% CI; dashed line is e",
         x = "Trials", y = "ê = 1 / p̂(no fixed point)") +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank())
}

# --- Animation (requires gganimate + gifski) ---
maybe_anim <- function(p, outfile, nframes = 200, fps = 30) {
  if (!requireNamespace("gganimate", quietly = TRUE) ||
      !requireNamespace("gifski", quietly = TRUE)) {
    message("gganimate/gifski not installed; skipping GIF. Saved PNG instead.")
    ggsave(sub("\\.gif$", ".png", outfile), p, width = 7, height = 5, dpi = 150)
    return(invisible(FALSE))
  }
  # Only executed if pkgs are available:
  p <- p + gganimate::transition_reveal(trial)
  anim <- gganimate::animate(
    p, nframes = nframes, fps = fps,
    renderer = gganimate::gifski_renderer()
  )
  gganimate::anim_save(outfile, anim)
  invisible(TRUE)
}

animate_convergence_uniform <- function(k_vec, outfile = "results/e_uniform.gif",
                                        nframes = 240, fps = 30) {
  df <- running_ci(k_vec)
  p <- ggplot(df, aes(trial, mean)) +
    geom_ribbon(aes(ymin = lo, ymax = hi), alpha = 0.18) +
    geom_line(linewidth = 0.9) +  # linewidth to silence ggplot warning
    geom_hline(yintercept = exp(1), linetype = "dashed") +
    labs(title = "Convergence of ê (Uniform-Sum): Trial {round(frame_along)}",
         subtitle = "95% MC CI ribbon; dashed line is e",
         x = "Trials", y = "Running mean of K (≈ e)") +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank())
  p$data <- df
  maybe_anim(p, outfile, nframes = nframes, fps = fps)
}

animate_convergence_derangements <- function(der_flags,
                                             outfile = "results/derangements_convergence.gif",
                                             nframes = 240, fps = 30) {
  df <- .derangements_curve_df(der_flags)
  lims <- .y_limits_robust(df$e_hat, cap = 10)
  p <- ggplot(df, aes(trial, e_hat)) +
    geom_ribbon(aes(ymin = lo, ymax = hi), alpha = 0.18, na.rm = TRUE) +
    geom_line(linewidth = 0.9, na.rm = TRUE) +
    geom_hline(yintercept = exp(1), linetype = "dashed") +
    coord_cartesian(ylim = lims) +
    labs(title = "Convergence of ê (Derangements): Trial {round(frame_along)}",
         subtitle = "95% CI ribbon; dashed line is e",
         x = "Trials", y = "ê = 1 / p̂(no fixed point)") +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank())
  p$data <- df
  maybe_anim(p, outfile, nframes = nframes, fps = fps)
}
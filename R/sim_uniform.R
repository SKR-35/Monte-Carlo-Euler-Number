# sim_uniform.R
# Uniform-sum trick: draw U~Unif(0,1) until cumulative sum > 1. Let K be the count.
# E[K] = e. Repeat to estimate e.

simulate_e_uniform <- function(reps = 10000L, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  k_vec <- integer(reps)
  for (r in seq_len(reps)) {
    s <- 0.0; k <- 0L
    while (s <= 1.0) { s <- s + runif(1); k <- k + 1L }
    k_vec[r] <- k
  }
  est <- mean(k_vec)
  se  <- stats::sd(k_vec) / sqrt(reps)
  ci  <- est + c(-1, 1) * 1.96 * se
  list(
    method = "uniform_sum",
    reps   = reps,
    estimate = est,
    se = se,
    ci95 = ci,
    k_vec = k_vec
  )
}

running_mean <- function(x) cumsum(x) / seq_along(x)
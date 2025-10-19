# sim_derangements.R
# Derangements: for size n, P(no fixed point) -> 1/e as n grows.
# Estimate p_hat = mean(derangement), then e_hat ≈ 1 / p_hat.

is_derangement <- function(p) {
  # p is a permutation vector 1..n
  !any(p == seq_along(p))
}

simulate_e_derangements <- function(n = 200L, reps = 5000L, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  der <- logical(reps)
  for (r in seq_len(reps)) {
    der[r] <- is_derangement(sample.int(n))
  }
  p_hat <- mean(der)
  e_hat <- 1 / p_hat
  # Simple (binomial) SE for p_hat; delta method for e_hat
  se_p  <- sqrt(p_hat * (1 - p_hat) / reps)
  se_e  <- se_p / (p_hat^2)
  ci_e  <- e_hat + c(-1, 1) * 1.96 * se_e
  list(
    method = "derangements",
    n = n,
    reps = reps,
    estimate = e_hat,
    se = se_e,
    ci95 = ci_e,
    derangements = der,
    p_hat = p_hat
  )
}

running_e_from_derangements <- function(der_flags) {
  # Running estimate 1 / mean(derangement) as trials accumulate
  p_run <- cumsum(der_flags) / seq_along(der_flags)
  1 / p_run
}
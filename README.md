## Monte-Carlo-Euler-Number

Two Monte Carlo estimators for **Euler’s number `e` ≈ 2.718281828…** + animated convergence.

## Methods

1) **Uniform-sum (E[K] = e):** draw `U ~ Unif(0,1)` repeatedly until the cumulative sum > 1.
   Let `K` be the number of draws. The sample mean of `K` estimates `e`.

2) **Derangements:** for permutations of size `n`, the probability of **no fixed points**
   tends to `1/e` as `n → ∞`. Estimate `p = P(derangement)` via simulation, then `e ≈ 1/p`.

## Quick start

```bash
# Uniform-sum estimator + GIF
Rscript R/main.R --mode uniform --reps 20000 --animate TRUE --outdir results

# Derangements estimator + GIF
Rscript R/main.R --mode derangements --n 200 --reps 20000 --animate TRUE --outdir results

# Compare both estimators (summary CSV)
Rscript R/main.R --mode compare --n 200 --reps 20000 --outdir results

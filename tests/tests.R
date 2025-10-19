# tests/tests.R
source("R/sim_uniform.R")
source("R/sim_derangements.R")

# keep CI fast & tolerant (stochastic tests)
set.seed(123)
u <- simulate_e_uniform(reps = 5000)
stopifnot(u$estimate > 2.5, u$estimate < 3.2)

set.seed(456)
d <- simulate_e_derangements(n = 200, reps = 3000)
stopifnot(d$estimate > 2.4, d$estimate < 3.5)

rm_mean <- running_mean(c(1,2,3,4))
stopifnot(all.equal(rm_mean, c(1,1.5,2,2.5)))
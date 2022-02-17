## Question 1
#' Simulated data set to test model
simulate_h03_q01 <- function() {
  N_generate <- 1e3
  sims <- data.table(
    alpha = 0.3,
    beta_area = 0.5,
    sigma = 1,
    area = runif(N_generate, 0.5, 10)
  )
  sims[, scale_area := as.numeric(scale(area))]
  sims[, mu := alpha + beta_area * scale_area]
  sims[, scale_food := rnorm(.N, mu, sigma)]
  return(sims)
}
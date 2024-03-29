## Question 1
# Simulated data set to test model
simulate_h02_q01 <- function() {
  N_generate <- 1e3
  sims <- data.table(
    alpha = 100,
    beta_height = 2,
    sigma = 1.5,
    height = runif(N_generate, 130, 170)
  )
  sims[, mu := alpha + beta_height * (height - mean(height))]
  sims[, weight := rnorm(.N, mu, sigma)]
}

# Predict weights from new heights
predict_weight_h02_q01 <- function(draws, new_values, mean_height) {
  setDT(draws)
  
  new_values <- data.table(height = new_values)
  
  out <- new_values[, draws[, rnorm(.N, alpha + beta_height * (.BY[[1]] - mean_height), sigma)],
                    by = height]
  setnames(out, 'V1', 'weight')
  return(out)
}

## Question 2
# Prior predictive simulation
priors_h02_q02 <- function() {
  N_generate <- 1e2
  priors <- data.table(
    alpha = rnorm(N_generate, 10, 5),
    beta_age = rlnorm(N_generate, 0, 1),
    sigma = rexp(N_generate, 1),
    age = runif(N_generate, 1, 12)
  )
  priors[, mu := alpha + beta_age * age]
  priors[, weight := rnorm(.N, mu, sigma)]
  
}

# Simulated data set to test model
simulate_h02_q02 <- function() {
  N_generate <- 1e2
  sims <- data.table(
    alpha = 10,
    beta_age = 3,
    sigma = 2,
    age = runif(N_generate, 1, 12)
  )
  sims[, mu := alpha + beta_age * age]
  sims[, weight := rnorm(.N, mu, sigma)]
}

## Question 3
# Simulated data set to test model
simulate_h02_q03 <- function() {
  N_generate <- 1e2
  sims <- data.table(
    # Add sex 1, 2
    sex = c(1, 2),
    # Add beta age and alpha for each
    beta_age = c(1, 1.5),
    alpha = c(10, 15),
    sigma = 2,
    age = runif(N_generate, 1, 12)
  )
  sims[, mu := alpha + beta_age * age, by = sex]
  sims[, weight := rnorm(.N, mu, sigma)]
}


# Contrasts
contrast_h02_q03 <- function(draws) {
  setDT(draws)
  
  sel_cols <- c('sigma', 'beta_age[1]', 'beta_age[2]', 'alpha[1]', 'alpha[2]')
  DT <- draws[, .SD, .SDcols = sel_cols]
  
  draws[, sim_age := floor(runif(.N, 0L, 12L))]
  draws[, predict_wt := (`alpha[1]` + `beta_age[1]` * sim_age) -
                        (`alpha[2]` + `beta_age[2]` * sim_age)]
  
  return(draws)  
}
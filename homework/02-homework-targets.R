N_generate <- 1e3

targets_homework_02 <- c(
  # Question 1 --------------------------------------------------------------
  # Data
  tar_target(
    DT_h02_q01,
    data_Howell1()[age > 18]
  ),
  # As list
  tar_target(
    DT_list_h02_q01,
    as.list(DT_h02_q01, N = nrow(DT_h02_q01))
  ),
  
  # Simulated
  tar_target(
    DT_sims_h02_q01,
  {sims <- data.table(
      alpha = 25,
      beta = 3,
      sigma = 2,
      height = runif(N_generate, 130, 170)
    )
  sims[, mu := alpha + beta * (height - mean(height))]
  sims[, weight := rnorm(.N, mu, sigma)]
  }),
  
  # Model
  tar_stan_mcmc(
    model_sims_h02_q01,
    file.path('stan', 'model_h02_q01.stan'),
    list(height = DT_sims_h02_q01$height - mean(DT_sims_h02_q01$height),
         weight = DT_sims_h02_q01$weight, 
         N = N_generate),
    chains = 1
  )
)

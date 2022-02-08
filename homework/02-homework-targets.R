targets_homework_02 <- c(
  # Question 1 --------------------------------------------------------------
  # Data
  tar_target(
    DT_h02_q01,
    data_Howell1()[age >= 18]
  ),
  
  # Simulated
  tar_target(
    DT_sims_h02_q01,
  {N_generate <- 1e3
   sims <- data.table(
      alpha = 100,
      beta_height = 2,
      sigma = 1.5,
      height = runif(N_generate, 130, 170)
    )
  sims[, mu := alpha + beta_height * (height - mean(height))]
  sims[, weight := rnorm(.N, mu, sigma)]
  }),
  
  # Model simulation
  tar_stan_mcmc(
    q01_sims,
    file.path('stan', 'h02_q01.stan'),
    list(height = DT_sims_h02_q01$height - mean(DT_sims_h02_q01$height),
         weight = DT_sims_h02_q01$weight, 
         N = nrow(DT_sims_h02_q01)),
    chains = 1,
    dir = compiled_dir
  ),
  
  # Model Howell1
  tar_stan_mcmc(
    q01,
    file.path('stan', 'h02_q01.stan'),
    list(height = DT_h02_q01$height - mean(DT_h02_q01$height),
         weight = DT_h02_q01$weight,
         N = nrow(DT_h02_q01)),
    chains = 1,
    dir = compiled_dir
  ),
  
  # Predict Howell1
  tar_target(
    predict_h02_q01,
    predict_heights(
      q01_draws_h02_q01,
      c(140, 160, 175),
      mean(DT_sims_h02_q01$height)
    )
  ),
  

  # Question 2 --------------------------------------------------------------
  # Data
  tar_target(
    DT_h02_q02,
    data_Howell1()[age < 13]
  ),
  # Priors
  tar_target(
    DT_priors_h02_q02,
    {N_generate <- 1e2
     priors <- data.table(
      alpha = rnorm(N_generate, 10, 5),
      beta_age = rlnorm(N_generate, 0, 1),
      sigma = rexp(N_generate, 1),
      age = runif(N_generate, 1, 12)
    )
    priors[, mu := alpha + beta_age * (age - mean(age))]
    priors[, weight := rnorm(.N, mu, sigma)]
    }),
  
  # Simulation
  tar_target(
    DT_sims_h02_q02,
    {N_generate <- 1e2
     sims <- data.table(
      alpha = 10,
      beta_age = 3,
      sigma = 2,
      height = runif(N_generate, 70, 150),
      age = runif(N_generate, 1, 12)
    )
    sims[, mu := alpha + beta_age * (age - mean(age))]
    sims[, weight := rnorm(.N, mu, sigma)]
    }),
  
  # Model simulation
  tar_stan_mcmc(
    q02_sims,
    file.path('stan', 'h02_q02.stan'),
    list(age = DT_sims_h02_q02$age,
         weight = DT_sims_h02_q02$weight, 
         N = nrow(DT_sims_h02_q02)),
    chains = 1,
    dir = compiled_dir
  ),
  
  # Model
  tar_stan_mcmc(
    q02,
    file.path('stan', 'h02_q02.stan'),
    list(age = DT_h02_q02$age,
         weight = DT_h02_q02$weight, 
         N = nrow(DT_h02_q02)),
    chains = 1,
    dir = compiled_dir
  ),
  

  # Render ------------------------------------------------------------------
  tar_render(
    render_h02,
    'homework/02-homework.Rmd'
  )

  
)

# brm(
#   weight ~ height,
#   data = tar_read(DT_list_h02_q01)
# )


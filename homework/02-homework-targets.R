targets_homework_02 <- c(
  # Question 1 --------------------------------------------------------------
  # Data
  tar_target(DT_h02_q01,
             data_Howell1()[age >= 18]),
  
  # Simulated
  tar_target(DT_sims_h02_q01,
             simulate_h02_q01()),
  
  # Model simulation
  tar_stan_mcmc(
    h02_q01_sims,
    file.path('stan', 'h02_q01.stan'),
    list(
      height = DT_sims_h02_q01$height - mean(DT_sims_h02_q01$height),
      weight = DT_sims_h02_q01$weight,
      N = nrow(DT_sims_h02_q01)
    ),
    chains = 1,
    dir = compiled_dir
  ),
  
  # Model Howell1
  tar_stan_mcmc(
    h02_q01,
    file.path('stan', 'h02_q01.stan'),
    list(
      height = DT_h02_q01$height - mean(DT_h02_q01$height),
      weight = DT_h02_q01$weight,
      N = nrow(DT_h02_q01)
    ),
    chains = 1,
    dir = compiled_dir
  ),
  
  # Predict Howell1
  tar_target(
    predict_h02_q01,
    predict_weight_h02_q01(
      h02_q01_draws_h02_q01,
      c(140, 160, 175),
      mean(DT_sims_h02_q01$height)
    )
  ),
  
  
  # Question 2 --------------------------------------------------------------
  # Data
  tar_target(DT_h02_q02,
             data_Howell1()[age < 13]),
  # Priors
  tar_target(DT_priors_h02_q02,
             priors_h02_q02()),
  
  # Simulation
  tar_target(DT_sims_h02_q02,
             simulate_h02_q02()),
  
  # Model simulation
  tar_stan_mcmc(
    h02_q02_sims,
    file.path('stan', 'h02_q02.stan'),
    list(
      age = DT_sims_h02_q02$age,
      weight = DT_sims_h02_q02$weight,
      N = nrow(DT_sims_h02_q02)
    ),
    chains = 1,
    dir = compiled_dir
  ),
  
  # Model
  tar_stan_mcmc(
    h02_q02,
    file.path('stan', 'h02_q02.stan'),
    list(
      age = DT_h02_q02$age,
      weight = DT_h02_q02$weight,
      N = nrow(DT_h02_q02)
    ),
    chains = 1,
    dir = compiled_dir
  ),
  
  # Question 3 --------------------------------------------------------------
  # Simulation
  tar_target(DT_sims_h02_q03,
             simulate_h02_q03()),
  
  # Model simulation
  tar_stan_mcmc(
    h02_q03_sims,
    file.path('stan', 'h02_q03.stan'),
    list(
      age = DT_sims_h02_q03$age,
      weight = DT_sims_h02_q03$weight,
      sex = DT_sims_h02_q03$sex,
      N = nrow(DT_sims_h02_q03),
      N_sex = DT_sims_h02_q03[, uniqueN(sex)]
    ),
    chains = 1,
    dir = compiled_dir
  ),
  
  # Model
  tar_stan_mcmc(
    h02_q03,
    file.path('stan', 'h02_q03.stan'),
    list(
      age = DT_h02_q02$age,
      weight = DT_h02_q02$weight,
      sex = DT_h02_q02$sex,
      N = nrow(DT_h02_q02),
      N_sex = DT_h02_q02[, uniqueN(sex)]
    ),
    chains = 1,
    dir = compiled_dir
  ),
  
  tar_target(
    q03_contrast,
    contrast_h02_q03(h02_q03_draws_h02_q03)
  ),
  
  # Render ------------------------------------------------------------------
  tar_render(render_h02,
             'homework/02-homework.Rmd')
  
  
)

# brm(
#   weight ~ height,
#   data = tar_read(DT_list_h02_q01)
# )

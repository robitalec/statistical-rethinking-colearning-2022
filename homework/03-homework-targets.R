targets_homework_03 <- c(
  # Question 1 --------------------------------------------------------------
  # Data
  tar_target(
    DT_h03_q01,
    data_foxes(scale = TRUE)
  ),
  
  # Simulated
  tar_target(
    DT_sims_h03_q01,
    simulate_h03_q01()
  ),
  
  # Model simulation
  tar_stan_mcmc(
    h03_q01_sims,
    file.path('stan', 'h03_q01.stan'),
    list(
      scale_food = DT_sims_h03_q01$scale_food,
      scale_area = DT_sims_h03_q01$scale_area,
      N = nrow(DT_sims_h03_q01)
    ),
    chains = 4,
    dir = compiled_dir
  ),
  
  # Model data
  tar_stan_mcmc(
    h03_q01,
    file.path('stan', 'h03_q01.stan'),
    list(
      scale_food = DT_h03_q01$scale_food,
      scale_area = DT_h03_q01$scale_area,
      N = nrow(DT_h03_q01)
    ),
    chains = 4,
    dir = compiled_dir
  ),
  
  
  # Question 2 --------------------------------------------------------------
  
  # Question 3 --------------------------------------------------------------
  
  # Render ------------------------------------------------------------------
  tar_render(render_h03,
             'homework/03-homework.Rmd')
  
  
)
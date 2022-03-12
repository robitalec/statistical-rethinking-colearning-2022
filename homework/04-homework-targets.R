targets_homework_04 <- c(
  # Question 1 --------------------------------------------------------------
  # Data
  tar_target(
    DT_marriage,
    data_marriage()
  ),
  
  # Model
  tar_stan_mcmc(
    h04_q01_m609,
    file.path('stan', 'h04_q01_m609.stan'),
    c(N = DT_marriage[, .N],
      N_index_married = DT_marriage[, uniqueN(index_married)],
      as.list(DT_marriage)),
    chains = 4,
    dir = compiled_dir
  ),
  
  tar_stan_mcmc(
    h04_q01_m610,
    file.path('stan', 'h04_q01_m610.stan'),
    c(N = DT_marriage[, .N],
      as.list(DT_marriage)),
    chains = 4,
    dir = compiled_dir
  ),
  
  # LOO
  tar_target(
    loo_m609,
    h04_q01_m609_mcmc_h04_q01_m609$loo()
  ),
  tar_target(
    loo_m610,
    h04_q01_m610_mcmc_h04_q01_m610$loo()
  ),
  tar_target(
    compare_h04_q01,
    loo_compare(loo_m609, loo_m610)
  ),
  
  

  # Question 2 --------------------------------------------------------------
  # Model
  tar_stan_mcmc(
    h04_q02,
    dir('stan', 'h04_q02', full.names = TRUE),
    list(
      scale_food = DT_foxes$scale_food,
      scale_weight = DT_foxes$scale_weight,
      scale_groupsize = DT_foxes$scale_groupsize,
      scale_area = DT_foxes$scale_area,
      N = nrow(DT_foxes)
    ),
    chains = 4,
    dir = compiled_dir
  ),
  
  # LOO
  tar_target(
    loo_h04_q02_a,
    h04_q02_mcmc_h04_q02_a$loo()
  ),
  tar_target(
    loo_h04_q02_f,
    h04_q02_mcmc_h04_q02_f$loo()
  ),
  tar_target(
    loo_h04_q02_fg,
    h04_q02_mcmc_h04_q02_fg$loo()
  ),
  tar_target(
    loo_h04_q02_ga,
    h04_q02_mcmc_h04_q02_ga$loo()
  ),
  tar_target(
    loo_h04_q02_fga,
    h04_q02_mcmc_h04_q02_fga$loo()
  ),
  
  

  # Question 3 --------------------------------------------------------------
  # Data
  tar_target(
    DT_cherry,
    data_cherry_blossoms(drop_na = TRUE)
  ),
  
  # Model
  tar_stan_mcmc(
    h04_q03,
    dir('stan', 'h04_q03', full.names = TRUE),
    c(as.list(DT_cherry),
      N = nrow(DT_cherry)
    ),
    chains = 4,
    dir = compiled_dir
  ),
  
  # LOO
  tar_target(
    loo_h04_q03_f1,
    h04_q03_mcmc_h04_q03_f1$loo()
  ),
  tar_target(
    loo_h04_q03_f2,
    h04_q03_mcmc_h04_q03_f2$loo()
  ),
  tar_target(
    loo_h04_q03_f3,
    h04_q03_mcmc_h04_q03_f3$loo()
  ),
  
  
  # Render ------------------------------------------------------------------
  tar_render(render_h04,
             'homework/04-homework.Rmd')
  
  
)
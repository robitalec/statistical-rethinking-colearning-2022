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
  # LOO
  tar_target(
    loo_h04_q02_direct,
    h03_q02_mcmc_h03_q02_direct$loo()
  ),
  tar_target(
    loo_h04_q02_total,
    h03_q02_mcmc_h03_q02_total$loo()
  ),
  tar_target(
    compare_h04_q02,
    loo_compare(loo_h04_q02_direct, loo_h04_q02_total)
  ),
  
  
  # Render ------------------------------------------------------------------
  tar_render(render_h04,
             'homework/04-homework.Rmd')
  
  
)
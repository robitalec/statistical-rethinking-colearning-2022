targets_homework_04 <- c(
  # Question 1 --------------------------------------------------------------
  # Data
  tar_target(
    DT_marriage,
    data_marriage()
  ),
  
  # LOO-PSIS: https://mc-stan.org/loo/reference/loo.html, https://mc-stan.org/loo/articles/loo2-with-rstan.html
  # WAIC: https://mc-stan.org/loo/reference/waic.html
  
  # Model
  tar_mcmc(
    h04_q01_m609,
    file.path('stan', 'h03_q01.stan'),
    c(N = DT_marriage[, .N],
      N_index_married[, uniqueN(index_married)],
      as.list(DT_marriage)),
    chains = 4,
    dir = compiled_dir
  ),
  
  # Render ------------------------------------------------------------------
  tar_render(render_h04,
             'homework/04-homework.Rmd')
  
  
)
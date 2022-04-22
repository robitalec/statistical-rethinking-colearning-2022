targets_homework_06 <- c(
  # Data
  tar_target(
    DT_reedfrogs,
    data_reedfrogs()
  ),
  
  # Question 1 --------------------------------------------------------------
  tar_target(
    h06_q01_sim,
    prior_sim_h06_q01(sigmas = c(0.1, seq(0.5, 5, by = 0.5)))
  ),
  
  # Question 2 --------------------------------------------------------------
  # Model
  zar_brms(
    h06_q02,
    surv | trials(density) ~ pred:size + (1 | tank),
    priors = c(prior(normal(0, 1), class = b),
               prior(exponential(1), class = sd),
               prior(normal(0, 1.5), class = Intercept)),
    family = binomial,
    data = DT_reedfrogs
  ),
  
  # Question 3 --------------------------------------------------------------
  # Model
  zar_brms(
    h06_q03,
    surv | trials(density) ~ pred:size + scale_density + (1 | tank),
    priors = c(prior(normal(0, 1), class = b),
               prior(exponential(1), class = sd),
               prior(normal(0, 1), class = Intercept)),
    family = binomial,
    data = DT_reedfrogs
  ),
  
  # Render ------------------------------------------------------------------
  tar_render(render_h06,
             'homework/06-homework.Rmd')
)

targets_homework_07 <- c(
  # Data
  tar_target(
    DT_bangladesh,
    data_bangladesh()
  ),
  
  # Question 1 --------------------------------------------------------------
  # Model
  zar_brms(
    name = h07_q01,
    formula = use_contraception ~ (1 | district),
    prior = c(
      prior(normal(0, 1.5), Intercept),
      prior(exponential(1), sd)
    ),
    data = DT_bangladesh,
    family = bernoulli()
  ),
  # Question 2 --------------------------------------------------------------

  
  # Question 3 --------------------------------------------------------------
  
  # Render ------------------------------------------------------------------
  tar_render(render_h07,
             'homework/07-homework.Rmd')
)

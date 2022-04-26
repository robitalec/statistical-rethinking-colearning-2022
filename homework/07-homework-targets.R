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
  
  # Plot
  tar_target(
    plot_district_contraception,
    plot_h07_q01(h07_q01_brms_sample, DT_bangladesh)
  ),
  
  # Question 2 --------------------------------------------------------------
  
  # Question 3 --------------------------------------------------------------
  # Model
  zar_brms(
    name = h07_q03_total,
    formula = use_contraception ~ urban + (1 | district),
    prior = c(
      prior(normal(0, 1.5), Intercept),
      prior(normal(0, 1), b),
      prior(exponential(1), sd)
    ),
    data = DT_bangladesh,
    family = bernoulli()
  ),
  
  # Render ------------------------------------------------------------------
  tar_render(render_h07,
             'homework/07-homework.Rmd')
)

targets_homework_05 <- c(
  # Data
  tar_target(
    DT_grants,
    data_grants()
  ),
  
  # Question 1 --------------------------------------------------------------
  # Model
  zar_brms(
    h05_q01,
    awards | trials(applications) ~ gender,
    priors = NULL,
    family = binomial(),
    data = DT
  ),
  
  
  # Question 2 --------------------------------------------------------------
  # Model

  # Question 3 --------------------------------------------------------------
  
  
  
  # Render ------------------------------------------------------------------
  tar_render(render_h05,
             'homework/05-homework.Rmd')
  
  
)
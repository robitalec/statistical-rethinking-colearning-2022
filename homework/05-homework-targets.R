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
    c(prior(normal(0, 1), class = 'b')),
    family = binomial(),
    data = DT_grants
  ),
  
  # Question 2 --------------------------------------------------------------
  # Model
  zar_brms(
    h05_q02,
    awards | trials(applications) ~ gender:discipline,
    c(prior(normal(0, 1), class = 'b')),
    family = binomial(),
    data = DT_grants
  ),
  
  # Question 3 --------------------------------------------------------------
  # No targets 
  
  
  # Render ------------------------------------------------------------------
  tar_render(render_h05,
             'homework/05-homework.Rmd')
  
  
)
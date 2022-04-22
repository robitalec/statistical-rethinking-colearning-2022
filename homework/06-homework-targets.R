targets_homework_06 <- c(
  # Data
  tar_target(
    DT_reedfrogs,
    data_reedfrogs()
  ),
  
  # Question 1 --------------------------------------------------------------

  
  # Question 2 --------------------------------------------------------------
  # Model
  # zar_brms(
  #   h06_q01,
  #   formula = ,
  #   priors = ,
  #   family = ,
  #   data = DT_reedfrogs
  # ),
  
  # Question 3 --------------------------------------------------------------
  
  
  # Render ------------------------------------------------------------------
  tar_render(render_h06,
             'homework/06-homework.Rmd')
)
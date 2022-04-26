targets_homework_07 <- c(
  # Data
  tar_target(
    DT_bangladesh,
    data_bangladesh()
  ),
  
  # Question 1 --------------------------------------------------------------
  # Model
  # zar_brms(
  # ),
  # Question 2 --------------------------------------------------------------

  
  # Question 3 --------------------------------------------------------------
  
  # Render ------------------------------------------------------------------
  tar_render(render_h07,
             'homework/07-homework.Rmd')
)

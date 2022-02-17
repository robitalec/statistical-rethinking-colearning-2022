targets_homework_03 <- c(
  # Question 1 --------------------------------------------------------------
  tar_target(
    DT_h03_q01,
    data_foxes(scaled = TRUE)
  ),
  tar_target(
    DT_sims_h03_q01,
    simulate_h03_q01()
  ),
  
  # Question 2 --------------------------------------------------------------
  
  # Question 3 --------------------------------------------------------------
  
  # Render ------------------------------------------------------------------
  tar_render(render_h03,
             'homework/03-homework.Rmd')
  
  
)
N_generate <- 1e3

targets_homework_02 <- c(
  # Question 1 --------------------------------------------------------------
  # Data
  tar_target(
    DT_h02_q01,
    data_Howell1()[age > 18]
  ),
  # As list
  tar_target(
    DT_list_h02_q01,
    as.list(DT_h02_q01, N = nrow(DT_h02_q01))
  ),

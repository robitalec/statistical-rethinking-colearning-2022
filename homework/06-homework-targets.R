
# Targets: Homework 06 ----------------------------------------------------


targets_homework05 <- c(
  # Question 01 -----------------------------------------------------------
  # simulate frog data 
  tar_target(
    data_sim,
    sim_data(1, 1)
  ),
  
  # plot simulated data on probability scale
  tar_target(
    plot_sim,
    sim_plot(data_sim)
  ),
  
  # save plot
  tar_target(
    save_plot,
    ggsave("graphics/homework-06_q1.png", plot_sim)
  )
  
  # Question 02 -----------------------------------------------------------
  
  # direct effect binomial GLM

  
  
  
  # Question 04 -----------------------------------------------------------
  
  
)

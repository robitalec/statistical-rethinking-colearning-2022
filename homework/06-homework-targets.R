
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
  ),
  
  # Question 02 -----------------------------------------------------------
  
  # load reed frogs data
  tar_target(
    frog_data,
    data_frog()
  ),
  
  # model
  zar_brms(
    frog_model,
    formula = surv | trials(density) ~ pred:size + (1 | tank),
    priors = c(prior(normal(0, 1), class = Intercept),
               prior(normal(0, 1), class = 'b'),
               prior(exponential(1), class = sd)),
    family = binomial(),
    data = frog_data,
    chains = 4,
    iter = 2000,
    cores = 4,
    save_model = NULL
  ),
  
  # save output for homework question
  tar_target(
    frog_summ, 
    write.csv(as.data.frame(posterior_summary(frog_model_brms_sample))[1:5, ], "outputs/homework-06_q02_summ.csv")
  )
  
  # Question 03 -------------------------------------------------------------

  
  
  # Question 04 -----------------------------------------------------------
  
  
)

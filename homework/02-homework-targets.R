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
  
  # Simulated
  tar_target(
    DT_sims_h02_q01,
  {sims <- data.table(
      alpha = 25,
      beta = 3,
      sigma = 2,
      height = runif(N_generate, 130, 170)
    )
  sims[, mu := alpha + beta * (height - mean(height))]
  sims[, weight := rnorm(.N, mu, sigma)]
  }),
  
  # Model
  tar_stan_mcmc(
    model_sims_h02_q01,
    file.path('stan', 'model_h02_q01.stan'),
    list(height = DT_sims_h02_q01$height - mean(DT_sims_h02_q01$height),
         weight = DT_sims_h02_q01$weight, 
         N = N_generate),
    chains = 1,
    dir = compiled_dir
  ),
  
  # Model Howell1
  tar_stan_mcmc(
    model_h02_q01,
    file.path('stan', 'model_h02_q01.stan'),
    DT_list_h02_q01,
    chains = 1,
    dir = compiled_dir
  )
)


post <- tar_read(model_h02_q01_draws_model_h02_q01)
setDT(post)


mean_height <- mean(DT_sims_h02_q01$height)
new_values <- data.table(height = c(140, 160, 175))

pred <- new_values[, 
  post[, rnorm(.N, alpha + beta_height * (.BY[[1]] - mean_height), sigma)],
  by = height]

pred[, height := factor(height)]
setnames(pred, 'V1', 'weight')
ggplot(pred, aes(x = height, y = weight)) + 
  stat_halfeye()
  

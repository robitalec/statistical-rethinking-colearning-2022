## Question 1
# Plot predicted district
plot_h07_q01 <- function(model, data) {
  pred <- data.table(add_linpred_draws(data, model, transform = TRUE))
  
  mean_obs <- data[, .(mean_use = mean(use_contraception)), .(district)]
  
  ggplot(aes(x = as.numeric(district)), data = pred) + 
    stat_pointinterval(aes(y = .linpred), color = 'blue', alpha = 0.3) +
    geom_point(aes(y = mean_use), data = mean_obs) + 
    labs(x = 'district', y = 'use_contraception') + 
    theme_minimal()
}
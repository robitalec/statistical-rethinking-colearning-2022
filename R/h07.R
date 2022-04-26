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

## Question 3
# Plot direct and total effects
plot_h07_q03 <- function(model_direct, model_total, data) {
  pred_total <- add_linpred_draws(data, model_total, transform = TRUE)
  
  mean_obs <- data[, .(mean_use = mean(use_contraception)), .(urban)]
  
  g_total <- ggplot(aes(x = urban), data = pred_total) + 
    stat_pointinterval(aes(y = .linpred), color = 'blue', alpha = 0.3) +
    geom_point(aes(y = mean_use), data = mean_obs) + 
    labs(x = 'urban', y = 'use_contraception', 'Total effect') + 
    ylim(0, 1) + 
    theme_minimal() 
  
  pred_direct <- add_linpred_draws(data, model_direct, transform = TRUE)
  
  mean_obs <- data[, .(mean_use = mean(use_contraception)), .(urban)]
  
  g_direct <- ggplot(aes(x = urban), data = pred_direct) + 
    stat_pointinterval(aes(y = .linpred), color = 'blue', alpha = 0.3) +
    geom_point(aes(y = mean_use), data = mean_obs) + 
    labs(x = 'urban', y = 'use_contraception', main = 'Direct effect') + 
    ylim(0, 1) + 
    theme_minimal() 
  
  
  g_total / g_direct
  
}
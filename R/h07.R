## Question 1
# Plot predicted district
plot_h07_q01 <- function(model, data) {
  pred <- data.table(add_predicted_draws(data, model))
  
  pred[, mean_obs := mean(use_contraception), .(district)]
  pred[, mean_pred := mean(.prediction), .(district)]
  
  ggplot(unique(pred[, .(mean_obs, mean_pred, district)]),
         aes(x = as.numeric(district))) + 
    geom_linerange(aes(ymin = mean_obs, ymax = mean_pred),
                   color = 'darkgrey') + 
    geom_point(aes(y = mean_obs)) + 
    geom_point(aes(y = mean_pred), color = 'blue') + 
    labs(x = 'district', y = 'use_contraception (black: observed, blue: predicted)') + 
    theme_minimal()
}
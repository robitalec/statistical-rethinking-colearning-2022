## Question 1
# Prior predictive simulation
prior_sim_h06_q01 <- function(sigmas) {
  DT <- data.table(rate = sigmas)
  
  gsigma <- ggplot(DT) + 
    stat_halfeye(aes(y = rate, xdist = dist_exponential(rate))) + 
    labs(x = expression(sigma), y = 'rate', title = "Exponential(rate)")
  
  galphabar <- ggplot() + 
    stat_halfeye(aes(xdist = dist_normal(0, 1))) + 
    labs(x = expression(bar(alpha)), y = '', title = "Normal(0, 1)")
  
  N <- 1e3
  DT <- DT[, .(x = rnorm(N, 0, rexp(N, .BY[[1]]))), by = rate]
  galphaj <- ggplot(DT) + 
    stat_halfeye(aes(x = x, y = factor(rate))) + 
    lims(x = c(-3, 3)) + 
    labs(x = expression(alpha["j"]), y = 'rate', title = expression("Normal"(bar(alpha), sigma)))
  
  gsigma + galphabar + galphaj + plot_layout(ncol = 1)
}

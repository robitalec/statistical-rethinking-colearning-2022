## Question 1
# Simulated data set to test model
simulate_h03_q01 <- function() {
  N_generate <- 1e3
  sims <- data.table(
    alpha = 0.3,
    beta_area = 0.5,
    sigma = 1,
    area = runif(N_generate, 0.5, 10)
  )
  sims[, scale_area := as.numeric(scale(area))]
  sims[, mu := alpha + beta_area * scale_area]
  sims[, scale_food := rnorm(.N, mu, sigma)]
  return(sims)
}

# Melt new food predictions
melt_fox_food_predictions <- function(draws, foxes) {
  new_area <- seq(min(foxes$scale_area), max(foxes$scale_area), length.out = 100)
  melted <- melt(data.table(draws), variable.name = 'new_area_index', 
                 measure.vars = patterns('pred_food'), value.name = 'pred_food')
  
  melted[, new_area_index := as.integer(gsub('pred_food\\[|\\]', '', new_area_index))]
  melted[, new_area := new_area[new_area_index]]
  return(melted)
}

# Plot new food predictions
plot_fox_food_predictions <- function(predicted, observed) {
  ggplot(predicted, aes(new_area, pred_food)) + 
    stat_lineribbon(color = NA) + 
    geom_point(size = 2, aes(scale_area, scale_food), data = observed) +
    theme_bw() + 
    scale_fill_scico_d(alpha = 0.25, palette = 'acton', direction = -1, end = 0.8) + 
    labs(x = 'scaled area', y = 'scaled food')
}

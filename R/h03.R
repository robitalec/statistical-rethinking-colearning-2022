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
  new_food <- seq(min(foxes$scale_food), max(foxes$scale_food), length.out = 100)
  melted <- melt(data.table(h03_q01_draws), variable.name = 'new_food_index', measure.vars = patterns('new_food'))
  
  melted[, new_food_index := as.integer(gsub('new_food\\[|\\]', '', new_food_index))]
  melted[, new_food := new_food[new_food_index]]
  return(melted)
}

# Plot new food predictions
plot_fox_food_predictions <- function(predicted, observed) {
  ggplot(predicted, aes(new_food, value)) + 
    stat_lineribbon(color = NA) + 
    geom_point(size = 2, aes(scale_food, scale_area), data = observed) +
    theme_bw() + 
    scale_fill_scico_d(alpha = 0.25, palette = 'acton', direction = -1, end = 0.8)
}

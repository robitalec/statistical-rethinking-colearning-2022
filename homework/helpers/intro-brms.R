# Intro to brms -----------------------------------------------------------
# Alec L. Robitaille



# Packages ----------------------------------------------------------------
library(palmerpenguins)
library(brms)
library(data.table)
library(dagitty)
library(ggdag)
library(tidybayes)
library(ggplot2)



# Data --------------------------------------------------------------------
# Load the palmer penguins data
DT <- data.table(penguins)



# DAG ---------------------------------------------------------------------
# Example relationships between body mass and bill length
dag <- dagify(
  Bill_Length ~ Body_Mass,
  exposure = 'Body_Mass',
  outcome = 'Bill_Length'
)
plot(dag)

# Adjustment sets
adjustmentSets(dag)



# Variables ---------------------------------------------------------------
# Scale the variables
DT[, scaled_bill_length := scale(bill_length_mm)]
DT[, scaled_body_mass := scale(body_mass_g)]

# Save the scaling attributes for bill length to reverse the scaling for plots later
attr_bill_length <- attributes(DT$scaled_bill_length)


# Priors ------------------------------------------------------------------
# Read more here: https://paul-buerkner.github.io/brms/reference/brmsformula.html
f <- brmsformula(scaled_bill_length ~ scaled_body_mass)

# Get the default priors, given the formula and data
default_priors <- get_prior(f, data = DT)

# Set priors 
priors <- c(
  prior(normal(0, 0.5), class = 'b'),
  prior(normal(0, 0.2), class = 'Intercept'),
  prior(exponential(1), class = 'sigma')
)

# Sample only the priors
sample_priors <- brm(
  formula = f,
  data = DT,
  prior = priors,
  sample_prior = 'only'
)

# Plot the sample priors
plot(sample_priors)

# Prior predictive simulation
# Set N and generate a range of body mass, randomly assigning a island id 
N <- 15
predict_DT <- data.table(
  body_mass_g = runif(N, 2500, 7000),
  index_island = sample(c(1, 2, 3), N, replace = TRUE)
)
predict_DT[, scaled_body_mass := scale(body_mass_g)]

# Predict the bill length for range of body mass, given the brms model 
predicted <- add_predicted_draws(predict_DT, sample_priors)

# Reverse the scaling on predicted bill length
predicted$prior_predicted_bill_length <- predicted$.prediction * 
  attr_bill_length$`scaled:scale` + attr_bill_length$`scaled:center`

# Plot the distribution of predicted values for each body mass in predict_DT
ggplot(predicted, aes(body_mass_g, prior_predicted_bill_length)) + 
  geom_point(size = 0.1, color = 'grey') + 
  stat_halfeye() + 
  theme_bw()

# Here, we could decide to adjust the priors, or move on to the model



# Model -------------------------------------------------------------------
f <- brmsformula(scaled_bill_length ~ scaled_body_mass)

# Set priors 
priors <- c(
  prior(normal(0, 0.3), class = 'b'),
  prior(normal(0, 0.2), class = 'Intercept'),
  prior(exponential(1), class = 'sigma')
)

# Fit the model, without priors
m <- brm(
  formula = f,
  data = DT,
  prior = priors
)

# Note: "Rows containing NAs were excluded from the model."



# Draws -------------------------------------------------------------------
plot(m)
summary(m)
conditional_effects(m)



# LOO ---------------------------------------------------------------------
loo(m)




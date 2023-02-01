# Intro to brms -----------------------------------------------------------
# Alec L. Robitaille



# Packages ----------------------------------------------------------------
# cmdstanr::install_cmdstan()

library(palmerpenguins)
library(brms)
library(data.table)
library(dagitty)
library(ggdag)
library(tidybayes)
library(ggplot2)

# Use cmdstanr as a backend
options('brms.backend' = 'cmdstanr')



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
  sample_prior = 'only',
  save_model = file.path('stan', '00-intro-brms-priors.stan')
)

# Plot the sample priors
plot(sample_priors)


# Prior predictive simulation ---------------------------------------------
## Prior simulated parameters
# Quick
conditional_effects(sample_priors)

# Or manual
# Get draws
draws <- as_draws_df(sample_priors)

# Extract N example lines
N <- 15
n_draws <- draws[seq.int(N),]

# Plot the prior predicted relationship between body mass and bill length
ggplot(n_draws) + 
  lims(x = c(-2, 2), y = c(-2, 2)) + 
  labs(x = 'scaled body mass', y = 'prior predicted scaled bill length') + 
  geom_abline(aes(intercept = Intercept, slope = b_scaled_body_mass))


## Model predicted
# Set N and generate a range of body mass
N <- 15
predict_DT <- data.table(
  body_mass_g = runif(N, 2500, 7000)
)
predict_DT[, scaled_body_mass := scale(body_mass_g)]

# Predict the bill length for range of body mass, given the brms model 
prior_predicted <- add_predicted_draws(predict_DT, sample_priors)

# Reverse the scaling on predicted bill length
prior_predicted$prior_predicted_bill_length <- prior_predicted$.prediction * 
  attr_bill_length$`scaled:scale` + attr_bill_length$`scaled:center`

# Plot the distribution of predicted values for each body mass in predict_DT
ggplot(prior_predicted, aes(body_mass_g, prior_predicted_bill_length)) + 
  geom_point(size = 0.1, color = 'grey') + 
  stat_halfeye() + 
  theme_bw()


# Here, we could decide to adjust the priors, or move on to the model
# In this case, I'm going to adjust the lower bound of the beta for 
#  bill length since we don't expect negative relationships between body 
#  mass and bill length

# Set priors 
priors_v2 <- c(
  prior(normal(0, 0.5), class = 'b', lb = 0),
  prior(normal(0, 0.2), class = 'Intercept'),
  prior(exponential(1), class = 'sigma')
)

# Sample only the priors
sample_priors_v2 <- brm(
  formula = f,
  data = DT,
  prior = priors_v2,
  sample_prior = 'only',
  save_model = file.path('stan', '00-intro-brms-priors-v2.stan')
)

# Quick
conditional_effects(sample_priors_v2)

# Or manual
# Get draws
draws_v2 <- as_draws_df(sample_priors_v2)

# Extract N example lines
N <- 15
n_draws_v2 <- draws_v2[seq.int(N),]

# Plot the prior predicted relationship between body mass and bill length
ggplot(n_draws_v2) + 
  lims(x = c(-2, 2), y = c(-2, 2)) + 
  labs(x = 'scaled body mass', y = 'prior predicted scaled bill length') + 
  geom_abline(aes(intercept = Intercept, slope = b_scaled_body_mass))



# Model -------------------------------------------------------------------
# Fit the model
m <- brm(
  formula = f,
  data = DT,
  prior = priors_v2,
  save_model = file.path('stan', '00-intro-brms.stan')
)

# Note: "Rows containing NAs were excluded from the model."



# Draws -------------------------------------------------------------------
plot(m)
summary(m)
conditional_effects(m)



# LOO ---------------------------------------------------------------------
loo(m)




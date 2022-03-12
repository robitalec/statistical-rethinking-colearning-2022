# Intro to brms -----------------------------------------------------------
# Alec L. Robitaille



# Packages ----------------------------------------------------------------
library(palmerpenguins)
library(brms)
library(data.table)
library(dagitty)
library(ggdag)



# Data --------------------------------------------------------------------
DT <- data.table(penguins)



# DAG ---------------------------------------------------------------------
dag <- dagify(
  Bill_Length ~ Island + Body_Mass,
  Body_Mass ~ Island,
  exposure = 'Body_Mass',
  outcome = 'Bill_Length'
)
plot(dag)

adjustmentSets(dag)



# Variables ---------------------------------------------------------------
DT[, scaled_bill_length := scale(bill_length_mm)]
DT[, scaled_body_mass := scale(body_mass_g)]
DT[, index_island := .GRP, by = island]



# Priors ------------------------------------------------------------------
# Read more here: https://paul-buerkner.github.io/brms/reference/brmsformula.html
f <- brmsformula(scaled_bill_length ~ scaled_body_mass[index_island])

default_priors <- get_prior(f, data = DT)

priors <- c(
  prior(normal(0, 0.5), class = 'b'),
  prior(normal(0, 0.2), class = 'Intercept'),
  prior(exponential(1), class = 'sigma')
)

sample_priors <- brm(
  formula = f,
  data = DT,
  prior = priors,
  sample_prior = 'only'
)

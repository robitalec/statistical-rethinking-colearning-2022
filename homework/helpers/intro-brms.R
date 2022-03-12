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

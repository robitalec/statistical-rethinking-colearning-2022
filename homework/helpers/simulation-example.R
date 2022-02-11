# === Simulation example --------------------------------------------------
# Alec L. Robitaille



# Packages ----------------------------------------------------------------
library(rethinking)
library(data.table)



# Functions ---------------------------------------------------------------
source('R/dag_plot.R')


# DAG ---------------------------------------------------------------------
dag <- dagify(
  km_hour ~ size + nostrils,
  exposure = 'size',
  outcome = 'km_hour'
)

dag_plot(dag)



# Simulation --------------------------------------------------------------
# Simulate horses
N <- 1e3
DT <- data.table(
  size = floor(runif(N, 0, 13))
)


# Simulate intercepts and slopes
DT[, intercept := 10]
DT[, slope_size := 0.4]
DT[, sigma := 1]

# Simulate speeeeeeeds
DT[, mu := intercept + slope_size * size]
DT[, km_hour := rnorm(.N, mu, sigma)]


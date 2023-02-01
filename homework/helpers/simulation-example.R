# === Simulation example --------------------------------------------------
# Alec L. Robitaille



# Packages ----------------------------------------------------------------
library(rethinking)
library(data.table)
library(dagitty)
library(ggdag)


# Functions ---------------------------------------------------------------
source('R/dag_plot.R')


# DAG ---------------------------------------------------------------------
dag <- dagify(
  km_hour ~ size,
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


# Simulate intercept and slope
DT[, intercept := 10]
DT[, slope_size := 0.4]
DT[, sigma := 1]

# Simulate speeeeeeeds
DT[, mu := intercept + slope_size * size]
DT[, km_hour := rnorm(.N, mu, sigma)]



# Models ------------------------------------------------------------------
m1 <- quap(
  alist(
    km_hour ~ dnorm(mu, sigma),
    mu <- intercept + slope_size * size,
    intercept ~ dnorm(1, 10),
    slope_size ~ dnorm(0, 1),
    sigma ~ dexp(1)
  ),
  data = as.list(DT[, .(size, km_hour)])
)

cbind(list(simulation = t(DT[1, .(intercept, slope_size, sigma)])), precis(m1))


m2 <- quap(
  alist(
    km_hour ~ dnorm(mu, sigma),
    mu <- intercept + slope_size * size,
    intercept ~ dnorm(10, 100),
    slope_size ~ dnorm(0, 100),
    sigma ~ dexp(10)
  ),
  data = as.list(DT[, .(size, km_hour)])
)

cbind(list(simulation = t(DT[1, .(intercept, slope_size, sigma)])), precis(m2))


m3 <- quap(
  alist(
    km_hour ~ dnorm(mu, sigma),
    mu <- intercept + slope_size * size,
    intercept ~ dnorm(100, 1000),
    slope_size ~ dnorm(10, 1000),
    sigma ~ dexp(100)
  ),
  data = as.list(DT[, .(size, km_hour)])
)

cbind(list(simulation = t(DT[1, .(intercept, slope_size, sigma)])), precis(m3))



m4 <- quap(
  alist(
    km_hour ~ dnorm(mu, sigma),
    mu <- intercept + slope_size * size,
    intercept ~ dnorm(0, 1),
    slope_size ~ dexp(1),
    sigma ~ dnorm(0, 10)
  ),
  data = as.list(DT[, .(size, km_hour)])
)

# Error in quap(alist(km_hour ~ dnorm(mu, sigma), mu <- intercept + slope_size *  : 
# initial value in 'vmmin' is not finite
# The start values for the parameters were invalid. This could be caused by missing values (NA) in the data or by start values outside the parameter constraints. If there are no NA values in the data, try using explicit start values.

m5 <- quap(
  alist(
    km_hour ~ dnorm(mu, sigma),
    mu <- intercept + slope_size * size,
    intercept ~ dnorm(10, 1),
    slope_size ~ dexp(1),
    sigma ~ dnorm(0, 10)
  ),
  data = as.list(DT[, .(size, km_hour)])
)
cbind(list(simulation = t(DT[1, .(intercept, slope_size, sigma)])), precis(m5))


m6 <- quap(
  alist(
    km_hour ~ dnorm(mu, sigma),
    mu <- intercept + slope_size * size,
    intercept ~ dexp(1),
    slope_size ~ dexp(1),
    sigma ~ dexp(1)
  ),
  data = as.list(DT[, .(size, km_hour)])
)
cbind(list(simulation = t(DT[1, .(intercept, slope_size, sigma)])), precis(m6))

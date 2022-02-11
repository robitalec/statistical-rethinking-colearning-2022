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




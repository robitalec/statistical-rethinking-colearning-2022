# === Packages ------------------------------------------------------------
# Alec L. Robitaille

library(conflicted)

library(targets)
library(tarchetypes)
library(renv)
conflict_prefer('autoload', 'renv')

library(zarg)

library(data.table)

library(stantargets)
library(cmdstanr)
library(loo)
conflict_prefer('compare', 'loo')
library(distributional)
library(rethinking)
library(brms)
conflict_prefer_all('brms', 'stats', quiet = TRUE)
conflict_prefer('dstudent_t', 'brms')

library(tidybayes)

library(ggplot2)
library(ggdist)
library(patchwork)
library(scico)

library(ggdag)
library(dagitty)

library(knitr)
library(rmarkdown)

library(png)
library(grid)

library(here)

library(palmerpenguins)

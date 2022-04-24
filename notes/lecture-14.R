# === Lecture 14 code, translated to brms ---------------------------------
# Alec L. Robitaille


# Packages ----------------------------------------------------------------
source('R/packages.R')
source('R/plot_rvars.R')


# Chimps ------------------------------------------------------------------
data(chimpanzees)
DT <- data.table(chimpanzees)
DT
DT[, treatment := .GRP, .(prosoc_left, condition)]
DT[, treatment := factor(treatment)]
DT[, block := factor(treatment)]
DT[, actor := factor(actor)]

default <- get_prior(
  pulled_left ~ (actor | treatment) + (treatment | block),
  family = bernoulli(),
  data = DT
)

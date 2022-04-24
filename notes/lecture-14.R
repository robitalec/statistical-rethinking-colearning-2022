# === Lecture 14 code, translated to brms ---------------------------------
# Alec L. Robitaille


# Packages ----------------------------------------------------------------
source('R/packages.R')
source('R/plot_rvars.R')


# Chimps ------------------------------------------------------------------
data(chimpanzees)
DT <- data.table(chimpanzees)
DT[, treatment := .GRP, .(prosoc_left, condition)]
DT[, treatment := factor(treatment)]
DT[, block := factor(treatment)]
DT[, actor := factor(actor)]

default <- get_prior(
  pulled_left ~ (treatment | actor) + (treatment | block),
  family = bernoulli(),
  data = DT
)

p <- c(prior(exponential(1), class = sd),
       prior(normal(0, 1), class = Intercept),
       prior(lkj(4), class = cor))

b <- brm(
  pulled_left ~ (treatment | actor) + (treatment | block),
  prior = p,
  family = bernoulli(),
  data = DT
)


draws <- data.table(spread_draws(b, r_actor[id,treatment]))

draws[, index_treatment := .GRP, treatment]

ggplot(draws) + 
  stat_pointinterval(aes(index_treatment, 
                         inv_logit(r_actor))) + 
  facet_wrap(~index_id) + 
  ylim(0, 1)

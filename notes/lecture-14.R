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


## Building up model complexity...
# Actor only
default <- get_prior(
  pulled_left ~ actor,
  family = bernoulli(),
  data = DT
)

p <- c(prior(exponential(1), class = sd),
       prior(normal(0, 1), class = Intercept))

b <- brm(
  pulled_left ~ (1 | actor),
  prior = p,
  family = bernoulli(),
  data = DT,
  cores = 4,
  file = 'models/l14.Rds',
  file_refit = 'on_change'
)

mcmc_areas(b, regex_pars = 'r_actor', transformations = inv_logit)

# Actor and block intercepts
default <- get_prior(
  pulled_left ~ (1 | actor + block),
  family = bernoulli(),
  data = DT
)

b2 <- brm(
  pulled_left ~ (1 | actor + block),
  prior = p,
  family = bernoulli(),
  data = DT,
  cores = 4,
  file = 'models/l14-ab.Rds',
  file_refit = 'on_change'
)

mcmc_areas(b2, regex_pars = 'r_actor', transformations = inv_logit)


# Treatment | actor + block
default <- get_prior(
  pulled_left ~ treatment + (treatment | actor + block),
  family = bernoulli(),
  data = DT
)

p3 <- c(prior(normal(0, 1.5), class = b),
        prior(exponential(1), class = sd),
        prior(normal(0, 1), class = Intercept),
        prior(lkj(4), class = cor))

b3 <- brm(
  pulled_left ~ treatment + (treatment | actor)  + (treatment | block),
  prior = p3,
  family = bernoulli(),
  data = DT,
  cores = 4,
  file = 'models/l14-t-ab.Rds',
  file_refit = 'on_change'
)

ranef(b3)
fixef(b3)
mcmc_areas(b3)
mcmc_areas(b3, regex_pars = 'r_actor', transformations = inv_logit)

pred <- data.table(add_predicted_draws(DT, b3))

pred[, mean_pred := mean(.prediction), .(actor, treatment, block)]
pred[, mean_obs := mean(pulled_left), .(actor, treatment, block)]

ggplot(unique(pred[, .(actor, treatment, block, mean_pred, mean_obs)])) + 
  geom_point(aes(interaction(treatment, actor), mean_obs)) + 
  geom_point(aes(interaction(treatment, actor), mean_pred), color = 'blue') +
  theme_minimal()
# === Lecture 13 code, translated to brms ---------------------------------
# Alec L. Robitaille


# Packages ----------------------------------------------------------------
source('R/packages.R')


# Chimps ------------------------------------------------------------------
data(chimpanzees)
DT <- data.table(chimpanzees)
DT[, treatment := .GRP, .(prosoc_left, condition)]
DT[, treatment := factor(treatment)]
DT[, block := factor(treatment)]
DT[, actor := factor(actor)]

default <- get_prior(
  pulled_left ~ treatment:block + (1 | actor),
  family = bernoulli(),
  data = d
)

p <- c(prior(normal(0, 1.5), class = b),
       prior(exponential(1), class = sd),
       prior(normal(0, 1), class = Intercept))

b <- brm(
  pulled_left ~ treatment:block + (1 | actor),
  prior = p,
  family = bernoulli(),
  data = DT
)

b$prior

summarise_draws(b)
plot_rvars(b, 'r_actor', nested = TRUE)



# Frogs -------------------------------------------------------------------
data(reedfrogs)
DT_frogs <- data.table(reedfrogs)

DT_frogs[, tank := .I]
DT_frogs[, pred := factor(pred)]
DT_frogs[, size := factor(size)]

default_p_f <- get_prior(
  surv | trials(density) ~ pred:size + (1 | tank),
  data = DT_frogs,
  family = binomial()
)

p_f <- c(prior(normal(0, 1), class = b),
         prior(exponential(1), class = sd),
         prior(normal(0, 1), class = Intercept)) 

b_f <- brm(
  surv | trials(density) ~ pred:size + (1 | tank),
  prior = p_f,
  data = DT_frogs,
  family = binomial()
)

pred_levels <- DT_frogs[, CJ(
  pred, 
  size, 
  density = 35,
  unique = TRUE
)]
N <- 100
new_data <- pred_levels[rep(seq.int(.N), N)]
new_data[, tank := seq(48, 48 + .N - 1)]

pred <- posterior_predict(
  b_f, 
  new_data, 
  re_formula = ~ (1 | tank),
  allow_new_levels = TRUE,
  sample_new_levels = 'uncertainty'
)
qplot(pred, binwidth = 1) + theme_minimal()

# Different distribution
pred_interv_levels <- DT_frogs[, CJ(
  size,
  pred,
  density = 35,
  unique = TRUE
)]
N <- 100
new_interv_data <- pred_interv_levels[rep(seq.int(.N), N)]
new_interv_data[, tank := seq(48, 48 + .N - 1)]
new_interv_data[, size := sample(unique(DT_frogs$size), .N, 
                                 prob = c(.25, .75),
                                 replace = TRUE)]

pred_interv <- posterior_predict(
  b_f, 
  new_interv_data, 
  re_formula = ~ (1 | tank),
  allow_new_levels = TRUE,
  sample_new_levels = 'uncertainty'
)
qplot(pred_interv, binwidth = 1) + theme_minimal()


# Contrast
qplot(pred - pred_interv, binwidth = 1) + 
  theme_minimal() + 
  geom_vline(xintercept = 0)


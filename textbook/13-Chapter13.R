# switching to tidyverse + brms following https://bookdown.org/content/4857/monsters-and-mixtures.html

# Multilevel Tadpoles -----------------------------------------------------

library(tidyverse)
library(brms)
library(tidybayes)

data(reedfrogs, package = "rethinking")
d <- reedfrogs
rm(reedfrogs)

d$tank <- 1:nrow(d)


b13.1 <- 
  brm(data = d, 
      family = binomial,
      surv | trials(density) ~ 0 + factor(tank),
      prior(normal(0, 1.5), class = b),
      iter = 2000, warmup = 1000, chains = 4, cores = 4,
      seed = 13,
      file = "textbook/b13.01")

# visualize distribution of probabilities
tibble(estimate = fixef(b13.1)[, 1]) %>% 
  mutate(p = inv_logit_scaled(estimate)) %>% 
  pivot_longer(estimate:p) %>% 
  mutate(name = if_else(name == "p", "expected survival probability", "expected survival log-odds")) %>% 
  
  ggplot(aes(x = value, fill = name)) +
  stat_dots(size = 0) +
  scale_fill_manual(values = c("orange1", "orange4")) +
  scale_y_continuous(breaks = NULL) +
  labs(title = "Tank-level intercepts from the no-pooling model",
       subtitle = "Notice now inspecting the distributions of the posterior means can offer insights you\nmight not get if you looked at them one at a time.") +
  theme(legend.position = "none",
        panel.grid = element_blank()) +
  facet_wrap(~ name, scales = "free_x")

# now create a multilevel model 
b13.2 <- 
  brm(data = d, 
      family = binomial,
      surv | trials(density) ~ 1 + (1 | tank),
      prior = c(prior(normal(0, 1.5), class = Intercept),  # bar alpha
                prior(exponential(1), class = sd)),        # sigma
      iter = 5000, warmup = 1000, chains = 4, cores = 4,
      sample_prior = "yes",
      seed = 13,
      file = "textbook/b13.02")

# compare models 
b13.1 <- add_criterion(b13.1, "waic")
b13.2 <- add_criterion(b13.2, "waic")

w <- loo_compare(b13.1, b13.2, criterion = "waic")

print(w, simplify = F)

# sample posterior 
post <- as_draws_df(b13.2)

post_mdn <- 
  coef(b13.2, robust = T)$tank[, , ] %>% 
  data.frame() %>% 
  bind_cols(d) %>%
  mutate(post_mdn = inv_logit_scaled(Estimate))

head(post_mdn)

# plot posterior estimates vs data points 
post_mdn %>%
  ggplot(aes(x = tank)) +
  geom_hline(yintercept = inv_logit_scaled(median(post$b_Intercept)), linetype = 2, size = 1/4) +
  geom_vline(xintercept = c(16.5, 32.5), size = 1/4, color = "grey25") +
  geom_point(aes(y = propsurv), color = "orange2") +
  geom_point(aes(y = post_mdn), shape = 1) +
  annotate(geom = "text", 
           x = c(8, 16 + 8, 32 + 8), y = 0, 
           label = c("small tanks", "medium tanks", "large tanks")) +
  scale_x_continuous(breaks = c(1, 16, 32, 48)) +
  scale_y_continuous(breaks = 0:5 / 5, limits = c(0, 1)) +
  labs(title = "Multilevel shrinkage!",
       subtitle = "The empirical proportions are in orange while the model implied proportions are the black circles. The dashed line is\nthe model-implied average survival proportion.") +
  theme(panel.grid.major = element_blank())

# plot population level distribution of survival
# this makes the output of `slice_sample()` reproducible
set.seed(13)

p1 <-
  post %>% 
  mutate(iter = 1:n()) %>% 
  slice_sample(n = 100) %>% 
  expand(nesting(iter, b_Intercept, sd_tank__Intercept),
         x = seq(from = -4, to = 5, length.out = 100)) %>%
  mutate(density = dnorm(x, mean = b_Intercept, sd = sd_tank__Intercept)) %>% 
  
  ggplot(aes(x = x, y = density, group = iter)) +
  geom_line(alpha = .2, color = "orange2") +
  scale_y_continuous(NULL, breaks = NULL) +
  labs(title = "Population survival distribution",
       subtitle = "log-odds scale") +
  coord_cartesian(xlim = c(-3, 4))


set.seed(13)

p2 <-
  post %>% 
  slice_sample(n = 8000, replace = T) %>% 
  mutate(sim_tanks = rnorm(n(), mean = b_Intercept, sd = sd_tank__Intercept)) %>% 
  
  ggplot(aes(x = inv_logit_scaled(sim_tanks))) +
  geom_density(size = 0, fill = "orange2", adjust = 0.1) +
  scale_y_continuous(NULL, breaks = NULL) +
  labs(title = "Probability of survival",
       subtitle = "transformed by the inverse-logit function")

library(patchwork)

(p1 + p2) &
  theme(plot.title = element_text(size = 12),
        plot.subtitle = element_text(size = 10))

# Varying Effects ---------------------------------------------------------

# simulate data
a_bar   <-  1.5
sigma   <-  1.5
n_ponds <- 60

set.seed(5005)

dsim <- 
  tibble(pond   = 1:n_ponds,
         ni     = rep(c(5, 10, 25, 35), each = n_ponds / 4) %>% as.integer(),
         true_a = rnorm(n = n_ponds, mean = a_bar, sd = sigma))

head(dsim)


# simulate survivors
set.seed(5005)

dsim <-
    dsim %>%
    mutate(si = rbinom(n = n(), prob = inv_logit_scaled(true_a), size = ni))

# no pooling estimates 
(
  dsim <-
    dsim %>%
    mutate(p_nopool = si / ni)
)

# partial pooling estimates 
b13.3 <- 
  brm(data = dsim, 
      family = binomial,
      si | trials(ni) ~ 1 + (1 | pond),
      prior = c(prior(normal(0, 1.5), class = Intercept),
                prior(exponential(1), class = sd)),
      iter = 2000, warmup = 1000, chains = 4, cores = 4,
      seed = 13,
      file = "textbook/b13.03")

print(b13.3)

# plot 
# we could have included this step in the block of code below, if we wanted to
p_partpool <- 
  coef(b13.3)$pond[, , ] %>% 
  data.frame() %>%
  transmute(p_partpool = inv_logit_scaled(Estimate))

dsim <- 
  dsim %>%
  bind_cols(p_partpool) %>% 
  mutate(p_true = inv_logit_scaled(true_a)) %>%
  mutate(nopool_error   = abs(p_nopool   - p_true),
         partpool_error = abs(p_partpool - p_true))

dfline <- 
  dsim %>%
  select(ni, nopool_error:partpool_error) %>%
  pivot_longer(-ni) %>%
  group_by(name, ni) %>%
  summarise(mean_error = mean(value)) %>%
  mutate(x    = c( 1, 16, 31, 46),
         xend = c(15, 30, 45, 60))

dsim %>% 
  ggplot(aes(x = pond)) +
  geom_vline(xintercept = c(15.5, 30.5, 45.4), 
             color = "white", size = 2/3) +
  geom_point(aes(y = nopool_error), color = "orange2") +
  geom_point(aes(y = partpool_error), shape = 1) +
  geom_segment(data = dfline, 
               aes(x = x, xend = xend, 
                   y = mean_error, yend = mean_error),
               color = rep(c("orange2", "black"), each = 4),
               linetype = rep(1:2, each = 4)) +
  annotate(geom = "text", 
           x = c(15 - 7.5, 30 - 7.5, 45 - 7.5, 60 - 7.5), y = .45, 
           label = c("tiny (5)", "small (10)", "medium (25)", "large (35)")) +
  scale_x_continuous(breaks = c(1, 10, 20, 30, 40, 50, 60)) +
  labs(title = "Estimate error by model type",
       subtitle = "The horizontal axis displays pond number. The vertical axis measures\nthe absolute error in the predicted proportion of survivors, compared to\nthe true value used in the simulation. The higher the point, the worse\nthe estimate. No-pooling shown in orange. Partial pooling shown in black.\nThe orange and dashed black lines show the average error for each kind\nof estimate, across each initial density of tadpoles (pond size).",
       y = "absolute error") +
  theme(panel.grid.major = element_blank(),
        plot.subtitle = element_text(size = 10))


# Multiple Cluster Types --------------------------------------------------

# skipping m13.4 - m13.6 because they use centered parameterization which is not possible in brms 


# Divergent Transitions ---------------------------------------------------
data(chimpanzees, package = "rethinking")
d <- chimpanzees
rm(chimpanzees)

d <-
  d %>% 
  mutate(actor     = factor(actor),
         block     = factor(block),
         treatment = factor(1 + prosoc_left + 2 * condition))


b13.4 <- 
  brm(data = d, 
      family = binomial,
      bf(pulled_left | trials(1) ~ a + b,
         a ~ 1 + (1 | actor) + (1 | block), 
         b ~ 0 + treatment,
         nl = TRUE),
      prior = c(prior(normal(0, 0.5), nlpar = b),
                prior(normal(0, 1.5), class = b, coef = Intercept, nlpar = a),
                prior(exponential(1), class = sd, group = actor, nlpar = a),
                prior(exponential(1), class = sd, group = block, nlpar = a)),
      iter = 2000, warmup = 1000, chains = 4, cores = 4,
      seed = 13,
      file = "textbook/b13.04")

# Multilevel Posterior Predictions ----------------------------------------

# posterior predictions for existing clusters 
chimp <- 2

nd <-
  d %>% 
  distinct(treatment) %>% 
  mutate(actor = chimp,
         block = 1)

labels <- c("R/N", "L/N", "R/P", "L/P")

f <-
  fitted(b13.4,
         newdata = nd) %>% 
  data.frame() %>% 
  bind_cols(nd) %>% 
  mutate(treatment = factor(treatment, labels = labels))

f
(
  chimp_2_d <-
    d %>% 
    filter(actor == chimp) %>% 
    group_by(treatment) %>% 
    summarise(prob = mean(pulled_left)) %>% 
    ungroup() %>% 
    mutate(treatment = factor(treatment, labels = labels))
)

post <- as_draws_df(b13.4)

f <-
  post %>% 
  pivot_longer(b_b_treatment1:b_b_treatment4) %>% 
  mutate(fitted = inv_logit_scaled(b_a_Intercept + value + `r_actor__a[1,Intercept]` + `r_block__a[1,Intercept]`)) %>% 
  mutate(treatment = factor(str_remove(name, "b_b_treatment"),
                            labels = labels)) %>% 
  select(name:treatment)

f
# the posterior summaries
(
  f <-
    f %>%
    group_by(treatment) %>%
    tidybayes::mean_qi(fitted)
)

# the empirical summaries
chimp <- 5

(
  chimp_5_d <-
    d %>% 
    filter(actor == chimp) %>% 
    group_by(treatment) %>% 
    summarise(prob = mean(pulled_left)) %>% 
    ungroup() %>% 
    mutate(treatment = factor(treatment, labels = labels))
)

f %>%
  ggplot(aes(x = treatment, y = fitted, group = 1)) +
  geom_ribbon(aes(ymin = .lower, ymax = .upper), fill = "orange1") +
  geom_line(color = "blue") +
  geom_point(data = chimp_5_d,
             aes(y = prob),
             color = "grey25") +
  ggtitle("Chimp #5",
          subtitle = "This plot is like the last except\nwe did more by hand.") +
  coord_cartesian(ylim = 0:1) +
  theme(plot.subtitle = element_text(size = 10))


# posterior predictions for new clusters 

# simulate average actor
f <-
  post %>% 
  pivot_longer(b_b_treatment1:b_b_treatment4) %>% 
  mutate(fitted = inv_logit_scaled(b_a_Intercept + value)) %>% 
  mutate(treatment = factor(str_remove(name, "b_b_treatment"),
                            labels = labels)) %>% 
  select(name:treatment) %>%
  group_by(treatment) %>%
  # note we're using 80% intervals
  mean_qi(fitted, .width = .8)

f

p1 <-
  f %>%
  ggplot(aes(x = treatment, y = fitted, group = 1)) +
  geom_ribbon(aes(ymin = .lower, ymax = .upper), fill = "orange1") +
  geom_line(color = "blue") +
  ggtitle("Average actor") +
  coord_cartesian(ylim = 0:1) +
  theme(plot.title = element_text(size = 14, hjust = .5))

p1


# simulate variation among actors
set.seed(13)

f <-
  post %>% 
  # simulated chimpanzees
  mutate(a_sim = rnorm(n(), mean = b_a_Intercept, sd = sd_actor__a_Intercept)) %>% 
  pivot_longer(b_b_treatment1:b_b_treatment4) %>% 
  mutate(fitted = inv_logit_scaled(a_sim + value)) %>% 
  mutate(treatment = factor(str_remove(name, "b_b_treatment"),
                            labels = labels)) %>% 
  group_by(treatment) %>%
  # note we're using 80% intervals
  mean_qi(fitted, .width = .8)

f

p2 <-
  f %>%
  ggplot(aes(x = treatment, y = fitted, group = 1)) +
  geom_ribbon(aes(ymin = .lower, ymax = .upper), fill = "orange1") +
  geom_line(color = "blue") +
  ggtitle("Marginal of actor") +
  coord_cartesian(ylim = 0:1) +
  theme(plot.title = element_text(size = 14, hjust = .5))

p2


# visualize multiple new actors
# how many simulated chimps would you like?
n_chimps <- 100

set.seed(13)

f <-
  post %>% 
  mutate(iter = 1:n()) %>% 
  slice_sample(n = n_chimps) %>% 
  # simulated chimpanzees
  mutate(a_sim = rnorm(n(), mean = b_a_Intercept, sd = sd_actor__a_Intercept)) %>% 
  pivot_longer(b_b_treatment1:b_b_treatment4) %>% 
  mutate(fitted = inv_logit_scaled(a_sim + value)) %>% 
  mutate(treatment = factor(str_remove(name, "b_b_treatment"),
                            labels = labels)) %>% 
  select(iter:treatment)

f

p3 <-
  f %>%
  ggplot(aes(x = treatment, y = fitted, group = iter)) +
  geom_line(alpha = 1/2, color = "orange3") +
  ggtitle("100 simulated actors") +
  coord_cartesian(ylim = 0:1) +
  theme(plot.title = element_text(size = 14, hjust = .5))

p3

# note: can also use fitted() for this
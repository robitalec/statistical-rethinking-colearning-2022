# switching to tidyverse + brms following https://bookdown.org/content/4857/monsters-and-mixtures.html


# Beta Binomial -----------------------------------------------------------

library(tidyverse)
library(ggthemes)

theme_set(
  theme_hc() +
    theme(axis.ticks.y = element_blank(),
          plot.background = element_rect(fill = "grey92"))
)

pbar  <- .5
theta <- 5

ggplot(data = tibble(x = seq(from = 0, to = 1, by = .01)),
       aes(x = x, y = rethinking::dbeta2(x, pbar, theta))) +
  geom_area(fill = canva_pal("Green fields")(4)[1]) +
  scale_x_continuous("probability space", breaks = c(0, .5, 1)) +
  scale_y_continuous(NULL, breaks = NULL) +
  ggtitle(expression(The~beta~distribution),
          subtitle = expression("Defined in terms of "*mu*" (i.e., pbar) and "*kappa*" (i.e., theta)"))

# going back to college applications with a beta binomial model 
data(UCBadmit, package = "rethinking") 
d <- 
  UCBadmit %>% 
  mutate(gid = ifelse(applicant.gender == "male", "1", "2"))
rm(UCBadmit)

library(brms)

# define custom family for brms 
beta_binomial2 <- custom_family(
  "beta_binomial2", dpars = c("mu", "phi"),
  links = c("logit", "log"), lb = c(NA, 2),
  type = "int", vars = "vint1[n]"
)

stan_funs <- "
  real beta_binomial2_lpmf(int y, real mu, real phi, int T) {
    return beta_binomial_lpmf(y | T, mu * phi, (1 - mu) * phi);
  }
  int beta_binomial2_rng(real mu, real phi, int T) {
    return beta_binomial_rng(T, mu * phi, (1 - mu) * phi);
  }
"

stanvars <- stanvar(scode = stan_funs, block = "functions")

# model 
b12.1 <-
  brm(data = d, 
      family = beta_binomial2,  # here's our custom likelihood
      admit | vint(applications) ~ 0 + gid,
      prior = c(prior(normal(0, 1.5), class = b),
                prior(exponential(1), class = phi)),
      iter = 2000, warmup = 1000, cores = 4, chains = 4,
      stanvars = stanvars,  # note our `stanvars`
      seed = 12,
      backend = "rstan",
      file = "textbook/b12.01")

print(b12.1)
post <- as_draws_df(b12.1)
head(post)


# compute differences between two genders 
library(tidybayes)

post %>% 
  transmute(da = b_gid1 - b_gid2) %>% 
  mean_qi(.width = .89) %>% 
  mutate_if(is.double, round, digits = 3)

# plot posterior 
post <- as.data.frame(post)

set.seed(12)

lines <-
  post %>% 
  mutate(iter  = 1:n(),
         p_bar = inv_logit_scaled(b_gid2)) %>% 
  slice_sample(n = 100) %>% 
  expand(nesting(iter, p_bar, phi),
         x = seq(from = 0, to = 1, by = .005)) %>% 
  mutate(density = pmap_dbl(list(x, p_bar, phi), rethinking::dbeta2))

str(lines)

lines %>% 
  ggplot(aes(x = x, y = density)) + 
  stat_function(fun = rethinking::dbeta2,
                args = list(prob = mean(inv_logit_scaled(post[, "b_gid2"])),
                            theta = mean(post[, "phi"])),
                size = 1.5, color = canva_pal("Green fields")(4)[4]) +
  geom_line(aes(group = iter),
            alpha = .2, color = canva_pal("Green fields")(4)[4]) +
  scale_y_continuous(NULL, breaks = NULL, limits = c(0, 3)) +
  labs(subtitle = "distribution of female admission rates",
       x = "probability admit")

# need custom functions because we have a custom family

expose_functions(b12.1, vectorize = TRUE)

# required to use `predict()`
log_lik_beta_binomial2 <- function(i, prep) {
  mu     <- prep$dpars$mu[, i]
  phi    <- prep$dpars$phi
  trials <- prep$data$vint1[i]
  y      <- prep$data$Y[i]
  beta_binomial2_lpmf(y, mu, phi, trials)
}

posterior_predict_beta_binomial2 <- function(i, prep, ...) {
  mu     <- prep$dpars$mu[, i]
  phi    <- prep$dpars$phi
  trials <- prep$data$vint1[i]
  beta_binomial2_rng(mu, phi, trials)
}

# required to use `fitted()`
posterior_epred_beta_binomial2 <- function(prep) {
  mu     <- prep$dpars$mu
  trials <- prep$data$vint1
  trials <- matrix(trials, nrow = nrow(mu), ncol = ncol(mu), byrow = TRUE)
  mu * trials
}

# now we can plot posterior validation check 
# the prediction intervals
predict(b12.1) %>%
  data.frame() %>% 
  transmute(ll = Q2.5,
            ul = Q97.5) %>%
  bind_cols(
    # the fitted intervals
    fitted(b12.1) %>% data.frame(),
    # the original data used to fit the model) %>% 
    b12.1$data
  ) %>% 
  mutate(case = 1:12) %>% 
  
  # plot!
  ggplot(aes(x = case)) +
  geom_linerange(aes(ymin = ll / applications, 
                     ymax = ul / applications),
                 color = canva_pal("Green fields")(4)[1], 
                 size = 2.5, alpha = 1/4) +
  geom_pointrange(aes(ymin = Q2.5  / applications, 
                      ymax = Q97.5 / applications, 
                      y = Estimate/applications),
                  color = canva_pal("Green fields")(4)[4],
                  size = 1/2, shape = 1) +
  geom_point(aes(y = admit/applications),
             color = canva_pal("Green fields")(4)[2],
             size = 2) +
  scale_x_continuous(breaks = 1:12) +
  scale_y_continuous(breaks = 0:5 / 5, limits = c(0, 1)) +
  labs(subtitle = "Posterior validation check",
       caption = expression(italic(Note.)*" A = admittance probability"),
       y = "A") +
  theme(axis.ticks.x = element_blank(),
        legend.position = "none")


# Negative Binomial  ------------------------------------------------------
rm(list=ls())
data(Kline, package = "rethinking")
d <- 
  Kline %>% 
  mutate(p          = rethinking::standardize(log(population)),
         contact_id = ifelse(contact == "high", 2L, 1L),
         cid        = contact)
rm(Kline)

print(d)

b12.2b <-
  brm(data = d, 
      family = negbinomial(link = "identity"),
      bf(total_tools ~ exp(b0) * population^b1 / g,
         b0 + b1 ~ 0 + cid,
         g ~ 1,
         nl = TRUE),
      prior = c(prior(normal(1, 1), nlpar = b0),
                prior(exponential(1), nlpar = b1, lb = 0),
                prior(exponential(1), nlpar = g, lb = 0),
                prior(exponential(1), class = shape)),
      iter = 2000, warmup = 1000, chains = 4, cores = 4,
      seed = 12,
      control = list(adapt_delta = .95),
      backend = "rstan",
      file = "homework/b12.02b") 

print(b12.2b)

b12.2b <- add_criterion(b12.2b, "loo")
loo(b12.2b)

d %>% 
  mutate(k = b12.2b$criteria$loo$diagnostics$pareto_k) %>% 
  filter(k > .7) %>% 
  select(culture, k)

# for the annotation
text <-
  distinct(d, cid) %>% 
  mutate(population  = c(150000, 110000),
         total_tools = c(57, 69),
         label       = str_c(cid, " contact"))

p2 <-
  fitted(b12.2b,
         newdata = nd,
         probs = c(.055, .945)) %>%
  data.frame() %>%
  bind_cols(nd) %>%
  
  ggplot(aes(x = population, group = cid, color = cid)) +
  geom_smooth(aes(y = Estimate, ymin = Q5.5, ymax = Q94.5, fill = cid),
              stat = "identity",
              alpha = 1/4, size = 1/2) +
  geom_point(data = bind_cols(d, b12.2b$criteria$loo$diagnostics),
             aes(y = total_tools, size = pareto_k),
             alpha = 4/5) +
  geom_text(data = text,
            aes(y = total_tools, label = label)) +
  scale_y_continuous(NULL, labels = NULL) +
  labs(subtitle = "gamma-Poisson model")

p2

# predictive distributions for each culture 
predict(b12.2b,
        summary = F) %>% 
  data.frame() %>% 
  set_names(d$culture) %>% 
  pivot_longer(everything(),
               names_to = "culture",
               values_to = "lambda") %>% 
  left_join(d) %>% 
  
  ggplot(aes(x = lambda, y = 0)) +
  stat_halfeye(point_interval = mean_qi, .width = .5,
               fill = canva_pal("Green fields")(4)[2],
               color = canva_pal("Green fields")(4)[1]) +
  geom_vline(aes(xintercept = total_tools),
             color = canva_pal("Green fields")(4)[3]) +
  scale_x_continuous(expression(lambda["[culture]"]), breaks = 0:2 * 100) +
  scale_y_continuous(NULL, breaks = NULL) +
  coord_cartesian(xlim = c(0, 210)) +
  facet_wrap(~ culture, nrow = 2)


# Zero-Inflated Outcomes --------------------------------------------------

# define parameters
prob_drink <- 0.2  # 20% of days
rate_work  <- 1    # average 1 manuscript per day

# sample one year of production
n <- 365

# simulate days monks drink
set.seed(365)
drink <- rbinom(n, size = 1, prob = prob_drink)

# simulate manuscripts completed
y <- (1 - drink) * rpois(n, lambda = rate_work)

d <-tibble(drink = factor(drink, levels = 1:0), y = y)

d %>% 
  ggplot(aes(x = y)) +
  geom_histogram(aes(fill = drink),
                 binwidth = 1, size = 1/10, color = "grey92") +
  scale_fill_manual(values = canva_pal("Green fields")(4)[1:2]) +
  xlab("Manuscripts completed") +
  theme(legend.position = "none")

# model zero-inflated Poisson
b12.3 <- 
  brm(data = d, 
      family = zero_inflated_poisson,
      y ~ 1,
      prior = c(prior(normal(1, 0.5), class = Intercept),
                prior(beta(2, 6), class = zi)),  # the brms default is beta(1, 1)
      iter = 2000, warmup = 1000, chains = 4, cores = 4,
      seed = 12,
      backend = "rstan",
      file = "textbook/b12.03") 

print(b12.3)

# proportion of days they drink is zi estimate 
# rate they finish manuscripts, when not drinking is exponentiated intercept
fixef(b12.3)[1, ] %>%
  exp()


# Ordered Categorical -----------------------------------------------------
data(Trolley, package = "rethinking")
d <- Trolley
rm(Trolley)

p1 <-
  d %>% 
  ggplot(aes(x = response, fill = ..x..)) +
  geom_histogram(binwidth = 1/4, size = 0) +
  scale_fill_gradient(low = canva_pal("Green fields")(4)[4],
                      high = canva_pal("Green fields")(4)[1]) +
  scale_x_continuous(breaks = 1:7) +
  theme(axis.ticks = element_blank(),
        axis.title.y = element_text(angle = 90),
        legend.position = "none")
p1

# cumulative proportion
p2 <-
  d %>%
  count(response) %>%
  mutate(pr_k     = n / nrow(d),
         cum_pr_k = cumsum(pr_k)) %>% 
  
  ggplot(aes(x = response, y = cum_pr_k, 
             fill = response)) +
  geom_line(color = canva_pal("Green fields")(4)[2]) +
  geom_point(shape = 21, color = "grey92", 
             size = 2.5, stroke = 1) +
  scale_fill_gradient(low = canva_pal("Green fields")(4)[4],
                      high = canva_pal("Green fields")(4)[1]) +
  scale_x_continuous(breaks = 1:7) +
  scale_y_continuous("cumulative proportion", 
                     breaks = c(0, .5, 1), limits = c(0, 1)) +
  theme(axis.ticks = element_blank(),
        axis.title.y = element_text(angle = 90),
        legend.position = "none")
p2

# log-cumulative-odds
logit <- function(x) log(x / (1 - x)) # convenience function

d %>%
  count(response) %>%
  mutate(pr_k     = n / nrow(d),
         cum_pr_k = cumsum(n / nrow(d))) %>% 
  mutate(alpha = logit(cum_pr_k) %>% round(digits = 2))

p3 <-
  d %>%
  count(response) %>%
  mutate(cum_pr_k = cumsum(n / nrow(d))) %>% 
  filter(response < 7) %>% 
  
  # we can do the `logit()` conversion right in `ggplot() 
  ggplot(aes(x = response, y = logit(cum_pr_k), fill = response)) +
  geom_line(color = canva_pal("Green fields")(4)[2]) +
  geom_point(shape = 21, colour = "grey92", 
             size = 2.5, stroke = 1) +
  scale_fill_gradient(low = canva_pal("Green fields")(4)[4],
                      high = canva_pal("Green fields")(4)[1]) +
  scale_x_continuous(breaks = 1:7, limits = c(1, 7)) +
  ylab("log-cumulative-odds") +
  theme(axis.ticks = element_blank(),
        axis.title.y = element_text(angle = 90),
        legend.position = "none")
p3

# plot ordered likelihood with cumulative probability
# primary data
d_plot <-
  d %>%
  count(response) %>%
  mutate(pr_k     = n / nrow(d),
         cum_pr_k = cumsum(n / nrow(d))) %>% 
  mutate(discrete_probability = ifelse(response == 1, cum_pr_k, cum_pr_k - pr_k))

# annotation
text <-
  tibble(text     = 1:7,
         response = seq(from = 1.25, to = 7.25, by = 1),
         cum_pr_k = d_plot$cum_pr_k - .065)

d_plot %>% 
  ggplot(aes(x = response, y = cum_pr_k,
             color = cum_pr_k, fill = cum_pr_k)) +
  geom_line(color = canva_pal("Green fields")(4)[1]) +
  geom_point(shape = 21, colour = "grey92", 
             size = 2.5, stroke = 1) +
  geom_linerange(aes(ymin = 0, ymax = cum_pr_k),
                 alpha = 1/2, color = canva_pal("Green fields")(4)[1]) +
  geom_linerange(aes(x = response + .025,
                     ymin = ifelse(response == 1, 0, discrete_probability), 
                     ymax = cum_pr_k),
                 color = "black") +
  # number annotation
  geom_text(data = text, 
            aes(label = text),
            size = 4) +
  scale_fill_gradient(low = canva_pal("Green fields")(4)[4],
                      high = canva_pal("Green fields")(4)[1]) +
  scale_color_gradient(low = canva_pal("Green fields")(4)[4],
                       high = canva_pal("Green fields")(4)[1]) +
  scale_x_continuous(breaks = 1:7) +
  scale_y_continuous("cumulative proportion", breaks = c(0, .5, 1), limits = c(0, 1)) +
  theme(axis.ticks = element_blank(),
        axis.title.y = element_text(angle = 90),
        legend.position = "none")

# model
# define the start values
inits <- list('Intercept[1]' = -2,
              'Intercept[2]' = -1,
              'Intercept[3]' = 0,
              'Intercept[4]' = 1,
              'Intercept[5]' = 2,
              'Intercept[6]' = 2.5)

inits_list <- list(inits, inits, inits, inits)

b12.4 <- 
  brm(data = d, 
      family = cumulative,
      response ~ 1,
      prior(normal(0, 1.5), class = Intercept),
      iter = 2000, warmup = 1000, cores = 4, chains = 4,
      inits = inits_list,# here we add our start values
      backend = 'rstan',
      file = "textbook/b12.04")  

print(b12.4)

# transform to probabilities (SDs no longer valid after this transformation)
b12.4 %>% 
  fixef() %>% 
  inv_logit_scaled() %>% 
  round(digits = 3)

# to get valid SD values with probabilities, we need to look at posterior
as_draws_df(b12.4) %>% 
  mutate_all(inv_logit_scaled) %>% 
  pivot_longer(starts_with("b_")) %>% 
  group_by(name) %>% 
  summarise(mean = mean(value),
            sd   = sd(value),
            ll   = quantile(value, probs = .025),
            ul   = quantile(value, probs = .975))

# add predictors 
b12.5 <- 
  brm(data = d, 
      family = cumulative,
      response ~ 1 + action + contact + intention + intention:action + intention:contact,
      prior = c(prior(normal(0, 1.5), class = Intercept),
                prior(normal(0, 0.5), class = b)),
      iter = 2000, warmup = 1000, cores = 4, chains = 4,
      seed = 12,
      backend = 'rstan',
      file = "textbook/b12.05")

print(b12.5)

# plot marginal posterior 
labs <- str_c("beta[", 1:5, "]")

as_draws_df(b12.5) %>% 
  select(b_action:`b_contact:intention`) %>% 
  set_names(labs) %>% 
  pivot_longer(everything()) %>% 
  
  ggplot(aes(x = value, y = name)) +
  geom_vline(xintercept = 0, alpha = 1/5, linetype = 3) +
  stat_gradientinterval(.width = .5, size = 1, point_size = 3/2, shape = 21,
                        point_fill = canva_pal("Green fields")(4)[3], 
                        fill = canva_pal("Green fields")(4)[1], 
                        color = canva_pal("Green fields")(4)[2]) +
  scale_x_continuous("marginal posterior", breaks = -5:0 / 4) +
  scale_y_discrete(NULL, labels = parse(text = labs)) +
  coord_cartesian(xlim = c(-1.4, 0))

# visualize differently 
nd <- 
  d %>% 
  distinct(action, contact, intention) %>% 
  mutate(combination = str_c(action, contact, intention, sep = "_"))

f <-
  fitted(b12.5,
         newdata = nd,
         summary = F)

f <-
  rbind(f[, , 1],
        f[, , 2],
        f[, , 3],
        f[, , 4],
        f[, , 5],
        f[, , 6],
        f[, , 7]) %>% 
  data.frame() %>% 
  set_names(pull(nd, combination)) %>% 
  mutate(response = rep(1:7, each = n() / 7),
         iter     = rep(1:4000, times = 7)) %>% 
  pivot_longer(-c(iter, response),
               names_to = c("action", "contact", "intention"),
               names_sep = "_",
               values_to = "pk") %>% 
  mutate(intention = intention %>% as.integer())


# to order our factor levels for `facet`
levels <- c("action=0, contact=0", "action=1, contact=0", "action=0, contact=1")

p1 <-
  f %>% 
  # unnecessary for these plots
  filter(response < 7) %>% 
  # this will help us define the three panels of the triptych
  mutate(facet = factor(str_c("action=", action, ", contact=", contact),
                        levels = levels)) %>% 
  # these next three lines allow us to compute the cumulative probabilities
  group_by(iter, facet, intention) %>% 
  arrange(iter, facet, intention, response) %>% 
  mutate(probability = cumsum(pk)) %>% 
  ungroup() %>% 
  # these next three lines are how we randomly selected 50 posterior draws
  nest(data = -iter) %>% 
  slice_sample(n = 50) %>%
  unnest(data) %>% 
  
  # plot!
  ggplot(aes(x = intention, y = probability)) +
  geom_line(aes(group = interaction(iter, response), color = probability),
            alpha = 1/10) +
  geom_point(data = d %>%  # wrangle the original data to make the dots
               group_by(intention, contact, action) %>% 
               count(response) %>% 
               mutate(probability = cumsum(n / sum(n)),
                      facet = factor(str_c("action=", action, ", contact=", contact),
                                     levels = levels)) %>% 
               filter(response < 7),
             color = canva_pal("Green fields")(4)[2]) +
  scale_color_gradient(low = canva_pal("Green fields")(4)[4],
                       high = canva_pal("Green fields")(4)[1]) +
  scale_x_continuous("intention", breaks = 0:1) +
  scale_y_continuous(breaks = c(0, .5, 1), limits = 0:1) +
  theme(legend.position = "none") +
  facet_wrap(~ facet)

p <-
  predict(b12.5,
          newdata = nd,
          ndraws = 1000,
          scale = "response",
          summary = F)

p2 <-
  p %>% 
  data.frame() %>% 
  set_names(pull(nd, combination)) %>% 
  pivot_longer(everything(),
               names_to = c("action", "contact", "intention"),
               names_sep = "_",
               values_to = "response") %>% 
  mutate(facet = factor(str_c("action=", action, ", contact=", contact),
                        levels = levels)) %>% 
  
  ggplot(aes(x = response, fill = intention)) +
  geom_bar(width = 1/3, position = position_dodge(width = .4)) +
  scale_fill_manual(values = canva_pal("Green fields")(4)[2:1]) +
  scale_x_continuous("response", breaks = 1:7) +
  theme(legend.position = "none") +
  facet_wrap(~ facet)

(p1 / p2) & theme(panel.background = element_rect(fill = "grey94"))


# Ordered Categorical Predictors ------------------------------------------

d <-
  d %>% 
  mutate(edu_new = 
           recode(edu,
                  "Elementary School" = 1,
                  "Middle School" = 2,
                  "Some High School" = 3,
                  "High School Graduate" = 4,
                  "Some College" = 5, 
                  "Bachelor's Degree" = 6,
                  "Master's Degree" = 7,
                  "Graduate Degree" = 8) %>% 
           as.integer())


b12.6 <- 
  brm(data = d, 
      family = cumulative,
      response ~ 1 + action + contact + intention + mo(edu_new),  # note the `mo()` syntax
      prior = c(prior(normal(0, 1.5), class = Intercept),
                prior(normal(0, 1), class = b),
                # note the new kinds of prior statements
                prior(normal(0, 0.143), class = b, coef = moedu_new),
                prior(dirichlet(2, 2, 2, 2, 2, 2, 2), class = simo, coef = moedu_new1)),
      iter = 2000, warmup = 1000, cores = 4, chains = 4,
      seed = 12,
      file = "textbook/b12.06")

library(GGally)

delta_labels <- c("Elem", "MidSch", "SHS", "HSG", "SCol", "Bach", "Mast", "Grad")

as_draws_df(b12.6) %>% 
  select(contains("simo_moedu_new1")) %>% 
  set_names(str_c(delta_labels[1:7], "~(delta[", 1:7, "])")) %>% 
  ggpairs() +
  theme(strip.text = element_text(size = 8))

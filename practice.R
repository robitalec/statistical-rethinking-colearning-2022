
# Practice from textbook

library(tidyverse)
library(rethinking)

# CHAPTER 3 ====

# Grid-sampling posterior distribution from globe-toss example ====

# Generate possible proportions of water covering globe between 0 and 1
p_grid <- seq(0, 1, length.out = 1000)

# Generate grid of prior probabilities
prob_p <- rep(1, 1000)

# Generate 1,000 comparisons
# (probability of data 6/9 tosses given the potential proportion)
prob_data <- dbinom(6, size = 9, prob = p_grid)

# Generate posterior distribution by multiplying comparisons by priors
# then dividing by the average probability
posterior <- prob_data * prob_p
posterior <- posterior / sum(posterior)

# Sample the posterior 1,000 times and plot
samples <- sample(p_grid, prob = posterior, size = 10000, replace = T)
plot(samples)

rethinking::dens(samples)

#  Get credible intervals (range of parameter values compatible with
#  the model and data) by sampling the posterior distribution

# 95% credible interval 
# (posterior distribution between 2.5th and 97.5th percentile)
# Using percentile interval
quantile(samples, c(0.025, 0.975))
# Using the highest posterior density 
# interval (narrowest interval containing specified probability mass)
HPDI(samples, prob = 0.95)


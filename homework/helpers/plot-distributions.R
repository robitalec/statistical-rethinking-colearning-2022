# === Plotting distributions ----------------------------------------------
# Alec L. Robitaille

# Basic+quick ggplot density plots
#   and more elaborate ggdist option



# Packages ----------------------------------------------------------------
library(ggplot2)
library(ggdist)
library(patchwork)


# Variables ---------------------------------------------------------------
# Number of random values
N <- 1e4

# ggplot theme
theme_set(theme_bw())



# Examples: qplot density -------------------------------------------------
# Normal(mean = 0, standard deviation = 1) 
qplot(rnorm(N, 0, 1), geom = 'density')

# Log Normal(mean = 0, standard deviation = 1)
qplot(rlnorm(N, 0, 1), geom = 'density')

# Exponential with rate 1
qplot(rexp(N, 1), geom = 'density')

## Adding labels, as if for prior predictive simulation
# Adult female black bear weight (kg) is distributed 
#   normally with a mean of 70kg and std of 15kg
qplot(rnorm(N, 70, 15), xlab = 'Adult female black bear weight', geom = 'density')



# Function ----------------------------------------------------------------
# Skeleton for an extensible ggdist wrapper
plot_distribution <- function(x, xlab = NULL) {
  ggplot(data.frame(x = x), aes(x)) +
    labs(x = xlab) + 
    stat_halfeye() + 
    theme_bw()
}




# Example: ggdist wrapper -------------------------------------------------
# Continuing with black bears... 
plot_distribution(rnorm(N, 70, 15))

# Eg. maybe if we want to stack options, for the std, to see how it impacts the prior
plot_distribution(rnorm(N, 70, 5), xlab = 'Weight ~ Normal(70, 5)') / 
  plot_distribution(rnorm(N, 70, 15), xlab = 'Weight ~ Normal(70, 15)') / 
  plot_distribution(rnorm(N, 70, 25), xlab = 'Weight ~ Normal(70, 25)') & 
  xlim(0, 150)

# Note with patchwork, the & symbol allows you to set graph settings for all
#  elements. So here we set the xlim to 0-150 for all three plots


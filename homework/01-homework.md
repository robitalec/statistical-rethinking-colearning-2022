Statistical Rethinking homework wk 1
================
Levi Newediuk

``` r
library(tidyverse)
library(rethinking)
```

    ## Warning: package 'cmdstanr' was built under R version 4.0.5

### **Question 1** Suppose the globe tossing data (Chapter 2) had turned out to be 4 water and 11 land. Construct the posterior distribution, using grid approximation. Use the same flat prior as in the book.

``` r
p_grid <- seq( from=0 , to=1 , length.out=20 )

# Define grid
p_grid <- seq(0, 1, length.out = 100)

# Define prior (flat, all = 1)
prior <- rep(1, 20)

# Compute likelihood of 4 water of 15 tosses (11 land) given p_grid
likelihood <- dbinom(4, 15, prob = p_grid)

# Compute product of likelihood and prior (posterior) and add to df with p_grid
probs_df <- data.frame(prob = p_grid,
                       prior,
                       post = likelihood * prior) %>%
  # Standardize the posterior
  mutate(std_post = post/sum(post))
```

``` r
# Plot the distribution of posterior probabilities for each parameter value (proportion water)

# Define function for plot
plot_posterior <- function(dat) {
  ggplot(dat, aes(x = p_grid, y = std_post)) +
    geom_point() +
    ylab('Posterior probability') +
    xlab('Proportion water')
}

# Plot
plot_posterior(probs_df)
```

![](01-homework_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### **Question 2** Now suppose the data are 4 water and 2 land. Compute the posterior again, but this time use a prior that is zero below p = 0.5 and a constant above p = 0.5. This corresponds to prior information that a majority of the Earth’s surface is water.

``` r
# Set the new likelihood for 4 water in 6 tosses
likelihood_2 <- dbinom(4, 6, prob = p_grid)

probs_df_2 <- probs_df %>%
  # Set the new prior to 0 if < 0.5 else 1
  mutate(prior = ifelse(prob < 0.5, 0, 1),
         # Compute the new posterior
         post = likelihood_2 * prior,
         # Standardize the new posterior
         std_post = post / sum(post))

# Plot
plot_posterior(probs_df_2)
```

![](01-homework_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

### **Question 3** For the posterior distribution from 2, compute 89% percentile and HPDI intervals. Compare the widths of these intervals. Which is wider? Why? If you had only the information in the interval, what might you misunderstand about the shape of the posterior distribution?

``` r
# Draw 10,000 samples from the posterior
samples_2 <- sample(probs_df_2$prob, 
                    prob = probs_df_2$std_post, 
                    size = 10000, replace = T)

# Taking a quick look at the samples...
head(samples_2)
```

    ## [1] 0.7373737 0.5858586 0.7777778 0.5757576 0.7878788 0.6666667

``` r
# Calculate percentile intervals
samples_2_PI <- PI(samples_2, prob = 0.89)

# And HPDI
samples_2_HPDI <- HPDI(samples_2, prob = 0.89)
```

The percentile interval assigns the probability mass to the centre of
the distribution, i.e., 5.5% in each tail. It is wider because it places
the interval with respect to the centre of the distribution and not the
best representation of the data. Because the probability mass is pushed
to the centre, may miss the most probable parameter value. The HPDI
assigns the interval to the narrowest interval containing the
probability mass, so it better represents the data and more likely to
capture the most likely parameter value. The intervals are mostly
similar if the distribution is normal, but when it is skewed the HPDI is
a better representation of the data.

In the plot, the HPDI interval is shown in red and the percentile
interval in blue. The percentil interval is wider and potentially misses
values at the lower end because the distribution is skewed

``` r
ggplot(data.frame(values = samples_2), aes(x = values)) +
  geom_density() +
  annotate('rect', xmin = samples_2_HPDI[1], xmax = samples_2_HPDI[2], ymin = 0, ymax = Inf, alpha = 0.3, colour = 'red', fill = 'red', linetype = 'dashed') +
  annotate('rect', xmin = samples_2_PI[1], xmax = samples_2_PI[2], ymin = 0, ymax = Inf, alpha = 0.3, colour = 'blue', fill = 'blue', linetype = 'dashed') +
  xlab('Proportion water')
```

![](01-homework_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

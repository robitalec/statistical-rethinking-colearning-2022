Statistical Rethinking homework wk 1
================
Levi Newediuk

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

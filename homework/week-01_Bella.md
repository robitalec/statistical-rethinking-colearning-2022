
## Homework Week 1

**Question 1:** Suppose the globe tossing question (Chapter 2) had
turned out to be 4 water and 11 land. Construct the posterior
distribution, using grid approximation. Use the same flat prior as in
the book.

Response: To change the observations and get a new posterior based on a
different dataset, adjust the likelihood

``` r
# define grid 
p_grid <- seq(from = 0, to = 1, length.out = 20)
# define uniform prior 
prior <- rep(1,20)
# compute likelihood at each value in grid
likelihood <- dbinom(4, size = 4+11, prob = p_grid)
# compute likelihood of likelihood and prior 
unstd.posterior <- likelihood * prior
# standardize posterior 
posterior <- unstd.posterior/sum(unstd.posterior)
# plot 
plot(p_grid, posterior, type = "b", 
     xlab = "probability of water", ylab = "posterior probability")
```

![](week-01_Bella_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

``` r
# sample 
set.seed(100)
samples <- sample(p_grid, prob = posterior, size = 10000, replace = T)
```

**Question 2:** Now suppose the data are 4 water and 2 land. Compute the
posterior again but this time use a prior that is zero below *p* = 0.5
and a constant above *p* = 0.5. This corresponds to prior information
that a majority of the Earth’s surface is water.

``` r
# define grid 
p_grid <- seq(from = 0, to = 1, length.out = 20)
# define new prior 
newprior <- ifelse(p_grid < 0.5, 0, 1)
# RICHARD's PRIOR - DISCUSS 
prior <- c(rep(0,500), rep(1,500))
# compute likelihood at each value in grid 
likelihood <- dbinom(4, size = 4+2, prob = p_grid)
# compute likelihood of likelihood and prior 
unstd.posterior <- likelihood * newprior
# standardize posterior 
posterior <- unstd.posterior/sum(unstd.posterior)
# plot 
plot(p_grid, posterior, type = "b", 
     xlab = "probability of water", ylab = "posterior probability")
```

![](week-01_Bella_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

``` r
# sample 
set.seed(100)
samples2 <- sample(p_grid, prob = posterior, size = 1e4, replace = T)
```

**Question 3:** For the posterior distribution from question 2, compute
89% percentile and HPDI intervals. Compare the widths of these
intervals. Which is wider? Why? If you only had the information in the
interval, what might you misunderstand about the shape of the posterior
distribution?

*Percentile Intervals:*

    ##        5%       94% 
    ## 0.5263158 0.8947368

*HPDI Intervals:*

    ##     |0.89     0.89| 
    ## 0.5263158 0.8421053

Response: The percentile interval is wider than the HPDI interval. This
is because the percentile interval assigns the same probability mass to
each **tail** whereas the HPDI interval calculates the narrowest
interval possible containing the specified probability mass (0.89). The
interval does not capture the distribution of values so by interpreting
only the interval you may misinterpret the probability of certain
parameter values.

**Question 4:** OPTIONAL CHALLENGE. Suppose there is bias in sampling so
that Land is more likely than Water to be recorded. Specifically, assume
that 1-in-5 (20%) of Water samples are accidentally recorded instead as
“Land”. First, write a generative simulation of this sampling process.
Assuming the true proportion of Water is 0.70, what proportion does your
simulation tend to produce instead? Second, using a simulated sample of
20 tosses, compute the unbiased posterior distribution of the true
proportion of water.

NOTE: Checked Richard’s answers for this one.

If there are 0.7/1 ways to sample water and 0.8/1 ways for water to be
reported as water - there are 0.7 x 0.8 ways t observe water (garden
multiplies independent events)

``` r
N <- 1e5
set.seed(100)
W <- rbinom(N, size = 20, prob = 0.7*0.8)
mean(W/20) # biased expectation
```

    ## [1] 0.560283

This is the biased expectation. Now estimate posterior distribution
using grid approximation, accounting for biased sampling rate.

``` r
# simulate data 
W <- rbinom(1, size=20, prob=0.7*0.8)

# compute posterior 
grid_p <- seq(from=0, to=1, len=100)
pr_p <- dbeta(grid_p, 1, 1)
prW <- dbinom(W, 20, grid_p*0.8)
post <- prW*pr_p
```

Now calculate posterior ignoring bias and plot to compare.

``` r
# simulate data 
W <- rbinom(1, size=20, prob=0.7*0.8)

# compute posterior 
grid_p <- seq(from=0, to=1, len=100)
pr_p <- dbeta(grid_p, 1, 1)
prW <- dbinom(W, 20, grid_p*0.8)
post <- prW*pr_p

# compute posterior ignoring bias
post_bad <- dbinom(W, 20, grid_p)

# plot
plot(grid_p, post, type = "l", lwd=4,
     xlab = "proportion water", ylab = "plausability")
lines(grid_p, post_bad, col = 2, lwd = 4)
```

![](week-01_Bella_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->
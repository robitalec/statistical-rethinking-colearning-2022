
## Homework Week 6

**Question 1:** Conduct a prior predictive simulation for the Reedfrog
model. By this I mean to simulate the prior distribution of tank
survival probabilities αj. Start by using this prior:

Survival \~ Binomial(ni, pi)  
logit(pi) = αtank  
αj ∼ Normal( ̄α, σ)  
̄α ∼ Normal(0, 1)  
σ ∼ Exponential(1)

Be sure to transform the αj values to the probability scale for plotting
and summary. How does increasing the width of the prior on σ change the
prior distribution of αj? You might try Exponential(10) and
Exponential(0.1) for example.

Used code below to simulate the priors.

``` r
n <- 1e4
  
abar <- rnorm(n, 0, 1)
sigma <- rexp(n, 1)
  
rnorm(n, mean = abars, sd = sigmas)
```

<img src="/home/icrichmond/Repositories/statistical-rethinking/graphics/homework-06_q1.png" width="2100" />

As sigma is decreased to allow for more variation, more extreme values
(0,1) become more likely - decreasing the reliability of the prior. This
is the same outcome as in regular logit models.

NOTE: My plot doesn’t go to 0 like Richard’s solution because I used
brms function `inv_logit_scaled` instead of rethinking function
`inv_logit`… is there a non-scaled version for brms that doesn’t require
loading rethinking?

**Question 2:** Revisit the Reedfrog survival data, data(reedfrogs).
Start with the varying effects model from the book and lecture. Then
modify it to estimate the causal effects of the treatment variables pred
and size, including how size might modify the effect of predation. An
easy approach is to estimate an effect for each combination of pred and
size. Justify your model with a DAG of this experiment.

**Question 3:** Now estimate the causal effect of density on survival.
Consider whether pred modifies the effect of density. There are several
good ways to include density in your Binomial GLM. You could treat it as
a continuous regression variable (possibly standardized). Or you could
convert it to an ordered category (with three levels). Compare the σ
(tank standard deviation) posterior distribution to σ from your model in
Problem 2. How are they different? Why?

**Question 4 (OPTIONAL):** Using your estimates from the previous
problems, compute the expected causal effect of removing predators from
a population of tadpoles with size and density distributed according to
this table:

| density | small | large |
|---------|-------|-------|
| 10      | 25%   | 25%   |
| 35      | 25%   | 25%   |

In other words, 25% of the population is in groups of 10 small tadpoles,
25% in groups of 10 large tadpoles, 25% in groups of 35 small tadpoles,
and 25% in groups of 25 large tadpoles. Think carefully about if and how
you should incorporate the tank varying effects in this calculation.

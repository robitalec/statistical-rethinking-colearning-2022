
## Homework Week 3

**Question 1:** The first two problems are based on the same data. The
data in `data (foxes)` are 116 foxes from 30 different urban groups in
England. These fox groups are like street gangs. Group size
(`groupsize`) varies from 2 to 8 individuals. Each group maintains its
own (almost exclusive) urban territory. Some territories are larger than
others. The `area` variable encodes this information. Some territories
also have more `avgfood` than others. And food influences the `weight`
of each fox, where F is `avgfood`, G is `groupsize`, A is `area`, and W
is `weight` . Use the backdoor criterion and estimate the total causal
influence of A on F. What effect would increasing the area of a
territory have on the amount of food inside it?

![](week-03_Bella_files/figure-gfm/draw-dag-1.png)<!-- -->

Start off by identifying backdoor pathways and the potential adjustments
that need to be made to the model to close backdoor paths:

``` r
dag1 <- dagitty("dag {
                A -> F 
                F -> G -> W 
                F -> W }")
adjustmentSets(dag1, exposure = "A", outcome = "F", effect = "total")
```

    ##  {}

There are no backdoor pathways of A -&gt; F (as seen in the DAG). So
building a model with F as a function of A is sufficient:

``` r
# standardize variables 
d$F <- standardize(d$avgfood)
d$A <- standardize(d$area)
# model
m1 <- quap(
  alist(
    F ~ dnorm(mu, sigma),
    mu <- a + bA*A,
    a ~ dnorm(0,0.2),
    bA ~ dlnorm(0,0.5), # area can only be positive so constrain to log normal
    sigma ~ dexp(1) 
  ), data = d
)

precis(m1)
```

    ##                mean         sd        5.5%     94.5%
    ## a     -8.230035e-07 0.04230754 -0.06761644 0.0676148
    ## bA     8.820368e-01 0.04329138  0.81284879 0.9512248
    ## sigma  4.662167e-01 0.03051635  0.41744570 0.5149877

![](week-03_Bella_files/figure-gfm/answer-1%20figure-1.png)<!-- -->

The model output suggests that increasing the area territory would
increase the amount of food available.

**Question 2:** Now infer both the total and direct causal effects of
adding food F to a territory on the weight W of foxes. Which covariates
do you need to adjust for in each case? In light of your estimates from
this problem and the previous one, what do you think is going on with
these foxes? Feel free to speculate - all that matters is that you
justify your speculation.

Total causal effects of F on W:

``` r
# standardize variables 
d$F <- standardize(d$avgfood)
d$W <- standardize(d$weight)
# model total effects
m2t <- quap(
  alist(
    W ~ dnorm(mu, sigma),
    mu <- a + bF*F,
    a ~ dnorm(0,0.2),
    bF ~ dnorm(0,0.5), 
    sigma ~ dexp(1) 
  ), data = d
)

precis(m2t)
```

    ##                mean         sd       5.5%     94.5%
    ## a      2.033927e-06 0.08359885 -0.1336051 0.1336091
    ## bF    -2.421130e-02 0.09088333 -0.1694604 0.1210378
    ## sigma  9.911249e-01 0.06465549  0.8877930 1.0944569

![](week-03_Bella_files/figure-gfm/answer-2%20figure-m2t-1.png)<!-- -->

Total causal model indicates that there is no relationship between
average food and weight of foxes.

To assess the direct causal effects of food on weight, we need to
stratify by group size (G) because it is currently an open backdoor path
(pipe). Let’s confirm using `dagitty`:

``` r
adjustmentSets(dag1, exposure = "F", outcome = "W", effect = "direct")
```

    ## { G }

Add G to the model:

``` r
# standardize variables 
d$F <- standardize(d$avgfood)
d$W <- standardize(d$weight)
# rescale group size so it is one unit 
d$G <- (d$groupsize - 2) / (8 - 2)

# model total effects
m2d <- quap(
  alist(
    W ~ dnorm(mu, sigma),
    mu <- a + bF*F + bG*G,
    a ~ dnorm(0,0.2),
    bF ~ dnorm(0,0.5),
    bG ~ dnorm(0, 2), 
    sigma ~ dexp(1) 
  ), data = d
)

precis(m2d)
```

    ##             mean         sd        5.5%      94.5%
    ## a      0.2777959 0.16743813  0.01019741  0.5453944
    ## bF     0.1671118 0.13361203 -0.04642598  0.3806497
    ## bG    -0.8540222 0.44573709 -1.56639612 -0.1416482
    ## sigma  0.9668899 0.06398972  0.86462198  1.0691578

We see the effect of group size on weight.

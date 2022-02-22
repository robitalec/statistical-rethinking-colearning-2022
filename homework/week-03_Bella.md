
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
adjustmentSets(dag1, exposure = "A", outcome = "F")
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

    ##               mean         sd        5.5%      94.5%
    ## a     4.089682e-05 0.04230933 -0.06757758 0.06765937
    ## bA    8.820343e-01 0.04329328  0.81284331 0.95122534
    ## sigma 4.662373e-01 0.03051971  0.41746091 0.51501371

![](week-03_Bella_files/figure-gfm/answer-1%20figure-1.png)<!-- -->

The model output suggests that increasing the area territory would
increase the amount of food available.

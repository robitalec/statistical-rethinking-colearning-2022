
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

    ##                mean         sd        5.5%      94.5%
    ## a     -5.701675e-07 0.04230753 -0.06761618 0.06761504
    ## bA     8.820371e-01 0.04329137  0.81284914 0.95122508
    ## sigma  4.662166e-01 0.03051633  0.41744562 0.51498759

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
    ## a     -5.646358e-08 0.08360017 -0.1336093 0.1336092
    ## bF    -2.421155e-02 0.09088502 -0.1694634 0.1210403
    ## sigma  9.911439e-01 0.06465858  0.8878070 1.0944808

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

    ##             mean         sd         5.5%      94.5%
    ## a      0.2771425 0.16744412  0.009534486  0.5447506
    ## bF     0.1665085 0.13362277 -0.047046499  0.3800635
    ## bG    -0.8520620 0.44576398 -1.564478891 -0.1396450
    ## sigma  0.9669613 0.06399849  0.864679354  1.0692432

We see the effect of group size on weight.

**Question 3:** Reconsider the Table 2 Fallacy example (from Lecture 6),
this time with an unobserved confound U that influences both smoking S
and stroke Y. Here’s the modified DAG:

![](week-03_Bella_files/figure-gfm/draw-dag-q3-1.png)<!-- -->

First use the backdoor criterion to determine an adjustment set that
allows you to estimate the causal effect of X on Y, i.e. P(Y\|do(X)).
Second explain the proper interpretation of each coefficient implied by
the regression model that corresponds to the adjustment set. Which
coefficients (slopes) are causal and which are not? There is no need to
fit any models. Just think through the implications.

Currently, there are several backdoors open:

U -&gt; S -&gt; X -&gt; Y  
A -&gt; S -&gt; X -&gt; Y  
A -&gt; X -&gt; Y

Based on this, I think we should stratify by A to close one set of
backdoors. Additionally, stratifying by S could close the backdoor
through X, however, it is a collider between A and U and so stratifying
by S would open that pathway and create collider bias. So, I would only
stratify by A.

Dagitty confirms that stratifying by A and S is required to estimate the
direct effect of X on Y:

``` r
adjustmentSets(dag2, exposure = "X", outcome = "Y", effect = "direct")
```

    ## { A, S }

In terms of which coefficients are causal and which are not:

A -&gt; Y  
S -&gt; Y  
U -&gt; Y X -&gt; Y

**Question 4-OPTIONAL CHALLENGE:** Write a synthetic data simulation for
the causal model shown in Problem 3. Be sure to include the unobserved
confound in the simulation. Choose any functional relationships that you
like—you don’t have to get the epidemiology correct. You just need to
honor the causal structure. Then design a regression model to estimate
the influence of X on Y and use it on your synthetic data. How large of
a sample do you need to reliably estimate P(Y\|do(X))? Define “reliably”
as you like, but justify your definition.

``` r
N <- 200 

b_AY <- 3 # direct effect of A on Y 
b_AS <- 2 # direct effect of A on S 
b_AX <- 2 # direct effect of A on X 
b_SX <- 2 # direct effect of S on X 
b_SY <- 3 # direct effect of S on Y 
b_XY <- 1 # direct effect of X on Y 
b_U <- 2 # direct effect of U on S and Y 

U <- 2*rbern(N, 0.5) - 1
A <- rnorm(N)
S <- rnorm(N, b_AS*A + b_U*U)
X <- rnorm(N, b_SX*S + b_AX*A)
Y <- rnorm(N, b_AY*A + b_SY*S + b_XY*X + b_U*U)
ds <- data.frame(A=A, S=S, X=X, U=U, Y=Y)

m4 <- quap(
  alist(
    X ~ dnorm(mu, sigma), 
    mu <- a + b_AY*A + b_SY*S,
    a ~ dnorm(0, 1),
    c(b_AY, b_SY) ~ dnorm(0, 1), 
    sigma ~ dexp(1)
  ), data = ds
)

precis(m4)
```

    ##             mean         sd        5.5%     94.5%
    ## a     0.06839909 0.06915086 -0.04211735 0.1789155
    ## b_AY  2.07164634 0.09882871  1.91369898 2.2295937
    ## b_SY  1.99308778 0.03127755  1.94310021 2.0430754
    ## sigma 0.97557509 0.04860807  0.89789001 1.0532602

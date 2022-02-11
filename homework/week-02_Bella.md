
## Homework Week 2

Set up libraries and dataframes

``` r
suppressMessages(library(rethinking))
suppressMessages(library(dplyr))
data(Howell1)
d <- Howell1
d2 <- d[Howell1$age >= 18, ]
```

**Question 1:** Construct a linear regression of weight as predicted by
height, using the adults (age 18 or greater) from the Howell1 dataset.
The heights listed below were recorded in the !Kung census, but weights
were not recorded for these individuals. Provide predicted weights and
89% compatibility intervals for each of these individuals. That is, fill
in the table below, using model-based predictions.

``` r
# priors
set.seed(2971) # setting seed so it is reproducible 
N <- 100 # 100 lines
a <- rnorm( N , 178 , 20 ) # use mean height from different pop.
b <- rlnorm( 1e4 , 0 ,1) # beta to log normal - restrict to positive values
xbar <- mean(d2$height)

# model
m <- quap(
  alist(
    weight ~ dnorm( mu , sigma ) ,
    mu <- a + b*( height - xbar ) ,
    a ~ dnorm( 60 , 20 ) ,
    b ~ dlnorm( 0 , 1 ) ,
    sigma ~ dunif( 0 , 50 )
  ) , data=d2 )

# simulate weight 
sim.weight <- as.data.frame(sim(m , data=list(height= c(140, 160, 175), Hbar = xbar)))
weight.PI <- as.data.frame(apply( sim.weight , 2 , PI , prob=0.89 )) # get 89% PIs across simulated weights
```

| individual | height | expected weight | 89% interval    |
|-----------:|-------:|----------------:|:----------------|
|          1 |    140 |          35.942 | 29.228 - 42.807 |
|          2 |    160 |          48.271 | 41.715 - 55.24  |
|          3 |    175 |          57.409 | 50.22 - 64.212  |

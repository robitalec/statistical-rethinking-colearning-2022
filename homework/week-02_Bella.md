
## Homework Week 2

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

**Question 2:** From the Howell1 dataset, consider only the people
younger than 13 years old. Estimate the causal association between age
and weight. Assume that age influences weight through two paths. First,
age influences height, and height influences weight. Second, age
directly influences weight through age-related changes in muscle growth
and body proportions. Use a linear regression to estimate the total (not
just direct) causal effect of each year of growth on weight. Be sure to
carefully consider the priors. Try using prior predictive simulation to
assess what they imply.

``` r
# age influences weight through a direct effect and indirect effect through height 
# total effect does not include height in model
m2 <- quap(
  alist(
    weight ~ dnorm( mu , sigma ) ,
    mu <- a + bA*age ,
    a ~ dnorm( 5 , 1 ) ,
    bA ~ dlnorm( 0 , 1 ) , # only positive values for age and height
    sigma ~ dexp(1) # exponential positive growth
  ) , data = d3 )

precis(m2)
```

    ##           mean         sd     5.5%    94.5%
    ## a     7.179131 0.33980530 6.636057 7.722206
    ## bA    1.373792 0.05243254 1.289994 1.457589
    ## sigma 2.507392 0.14535399 2.275089 2.739696

``` r
# do a prior predictive simulation to test prior performance
n <- 25
sample_mu <- rnorm( n , 5 , 1 )
sample_bA <- rlnorm(n, 0, 1)
plot( NULL , xlim=range(d3$age) , ylim=range(d3$weight) )
for ( i in 1:n ) abline( sample_mu[i] , sample_bA[i] , lwd=3 , col=2 )
```

![](week-02_Bella_files/figure-gfm/question-2-1.png)<!-- -->

**Question 3:** Now suppose the causal association between age and
weight might be different for boys and girls. Use a single linear
regression, with a categorical variable for sex, to estimate the total
causal effect of age on weight separately for boys and girls. How do
girls and boys differ? Provide one or more posterior contrasts as a
summary.

``` r
# make sex an index variable
d3$sex <- ifelse( d3$male==1 , 2 , 1 ) # males = 2, females = 1
# model with categorical variable
m3 <- quap(
  alist(
    weight ~ dnorm( mu , sigma ) ,
    mu <- a[sex] + bA[sex]*age , # add sex as a categorical variable
    a[sex] ~ dnorm( 5 , 1 ) ,
    bA[sex] ~ dlnorm( 0 , 1 ) , # only positive values for age and height
    sigma ~ dexp(1) # exponential positive growth
  ) , data = d3 )
# plot both regression lines 
plot( d3$age , d3$weight , lwd=3, col=ifelse(d3$male==1,4,2) , xlab="age (years)" , ylab="weight (kg)" )
Aseq <- 0:12 # 13 years of age
# girls
muF <- link(m3,data=list(age=Aseq,sex=rep(1,13)))
shade( apply(muF,2,PI,0.99) , Aseq , col=col.alpha(2,0.5) )
lines( Aseq , apply(muF,2,mean) , lwd=3 , col=2 )
# boys
muM <- link(m3,data=list(age=Aseq,sex=rep(2,13)))
shade( apply(muM,2,PI,0.99) , Aseq , col=col.alpha(4,0.5) )
lines( Aseq , apply(muM,2,mean) , lwd=3 , col=4 )
```

![](week-02_Bella_files/figure-gfm/question-3-1.png)<!-- -->

``` r
# get posterior contrast at all ages 
Aseq <- 0:12
mu1 <- sim(m3,data=list(age=Aseq,sex=rep(1,13)))
mu2 <- sim(m3,data=list(age=Aseq,sex=rep(2,13)))
mu_contrast <- mu1
for ( i in 1:13 ) mu_contrast[,i] <- mu2[,i] - mu1[,i]
plot( NULL , xlim=c(0,13) , ylim=c(-15,15) , xlab="age" , ylab="weight difference (boys-girls)" )

for ( p in c(0.5,0.67,0.89,0.99) )
shade( apply(mu_contrast,2,PI,prob=p) , Aseq )

abline(h=0,lty=2,lwd=2)
```

![](week-02_Bella_files/figure-gfm/question-3-2.png)<!-- --> Boys tend
to be slightly heavier than girls and the effect increases as age
increases. Not a huge difference though.

**Question 4:** The data in data(Oxboys) (rethinking package) are growth
records for 26 boys measured over 9 periods. I want you to model their
growth. Specifically, model the increments in growth from one period
(Occasion in the data table) to the next. Each increment is simply the
difference between height in one occasion and height in the previous
occasion. Since none of these boys shrunk during the study, all of the
growth increments are greater than zero. Estimate the posterior
distribution of these increments. Constrain the distribution so it is
always positive—it should not be possible for the model to think that
boys can shrink from year to year. Finally compute the posterior
distribution of the total growth over all 9 occasions.

``` r
data(Oxboys)
d <- Oxboys

# convert data to growth increments
d$delta <- NA
for ( i in 1:nrow(d) ) {
    if ( d$Occasion[i] > 1 ) d$delta[i] <- d$height[i] - d$height[i-1]
}
d <- d[ !is.na(d$delta) , ]

# prior simulation
n <- 1e3
alpha <- rnorm(n,0,0.1)
sigma <- rexp(n,3)
delta_sim <- rlnorm(n,alpha,sigma)
dens(delta_sim)
```

![](week-02_Bella_files/figure-gfm/question-4-1.png)<!-- -->

``` r
# the model
m4 <- quap(
    alist(
        delta ~ dlnorm( alpha , sigma ),
        alpha ~ dnorm( 0 , 0.1 ),
        sigma ~ dexp( 3 )
    ), data=list(delta=d$delta) )

# compute posterior sum of 8 increments
post <- extract.samples(m4)

dsim <- rlnorm(1e3,post$alpha,post$sigma)
dens(dsim)
```

![](week-02_Bella_files/figure-gfm/question-4-2.png)<!-- -->

``` r
inc_sum <- sapply( 1:1000 , function(s) sum(rlnorm(8,post$alpha[s],post$sigma[s])) )
dens(inc_sum)
```

![](week-02_Bella_files/figure-gfm/question-4-3.png)<!-- -->

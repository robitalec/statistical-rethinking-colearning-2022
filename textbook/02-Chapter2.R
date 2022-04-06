#### Probability #### 
# six water tosses in 9 attempts
# binomial distribution because there are 2 discrete outcomes 
dbinom(6, size = 9, prob = 0.5)

#### Grid Approximation #### 
# define grid 
p_grid <- seq(from = 0, to = 1, length.out = 20)
# define prior 
prior <- rep(1,20)
# try different priors
prior <- ifelse(p_grid < 0.5, 0, 1)
prior <- exp(-5*abs(p_grid - 0.5))
# compute likelihood at each value in grid 
likelihood <- dbinom(6, size = 9, prob = p_grid)
# compute likelihood of likelihood and prior 
unstd.posterior <- likelihood * prior
# standardize posterior 
posterior <- unstd.posterior/sum(unstd.posterior)
# plot 
plot(p_grid, posterior, type = "b", 
     xlab = "probability of water", ylab = "posterior probability")

#### Quadratic Approximation ####
library(rethinking)
globe.qa <- quap(alist(
    W ~ dbinom( W+L ,p) , # binomial likelihood
    p ~ dunif(0,1) # uniform prior
  ),
  data=list(W=6,L=3) )
# display summary of quadratic approximation
precis( globe.qa )
# check the calculation with quap
# analytical calculation
W <- 6
L <- 3
curve( dbeta( x , W+1 , L+1 ) , from=0 , to=1 )
# quadratic approximation
curve( dnorm( x , 0.67 , 0.16 ) , lty=2 , add=TRUE )


#### Practice Questions ####
# question 2M1 
## a) W, W, W
# to change the observations and get a new posterior based on a different dataset, edit the likelihood line
# define grid 
p_grid <- seq(from = 0, to = 1, length.out = 20)
# define uniform prior 
prior <- rep(1,20)
# compute likelihood at each value in grid 
likelihood1 <- dbinom(3, size = 3, prob = p_grid)
## a) W, W, W
# compute likelihood of likelihood and prior 
unstd.posterior1 <- likelihood1 * prior
# standardize posterior 
posterior1 <- unstd.posterior1/sum(unstd.posterior1)
# plot 
plot(p_grid, posterior1, type = "b", 
     xlab = "probability of water", ylab = "posterior probability")
## b) W, W, W, L
# compute likelihood at each value in grid 
likelihood2 <- dbinom(3, size = 4, prob = p_grid)
# compute likelihood of likelihood and prior 
unstd.posterior2 <- likelihood2 * prior
# standardize posterior 
posterior2 <- unstd.posterior2/sum(unstd.posterior2)
# plot 
plot(p_grid, posterior2, type = "b", 
     xlab = "probability of water", ylab = "posterior probability")
## c) L, W, W, L, W, W, W
# compute likelihood at each value in grid 
likelihood3 <- dbinom(5, size = 7, prob = p_grid)
# compute likelihood of likelihood and prior 
unstd.posterior3 <- likelihood3 * prior
# standardize posterior 
posterior3 <- unstd.posterior3/sum(unstd.posterior3)
# plot 
plot(p_grid, posterior3, type = "b", 
     xlab = "probability of water", ylab = "posterior probability")


# question 2M2
##  a prior for p that is equal to zero when p < 0.5 and is a positive constant when p ≥ 0.5
# define new prior 
newprior <- ifelse(p_grid < 0.5, 0, 1)
## a) W, W, W
# compute likelihood of likelihood and prior 
unstd.posterior1 <- likelihood1 * newprior
# standardize posterior 
posterior1 <- unstd.posterior1/sum(unstd.posterior1)
# plot 
plot(p_grid, posterior1, type = "b", 
     xlab = "probability of water", ylab = "posterior probability")
## b) W, W, W, L
# compute likelihood of likelihood and prior 
unstd.posterior2 <- likelihood2 * newprior
# standardize posterior 
posterior2 <- unstd.posterior2/sum(unstd.posterior2)
# plot 
plot(p_grid, posterior2, type = "b", 
     xlab = "probability of water", ylab = "posterior probability")
## c) L, W, W, L, W, W, W
# compute likelihood of likelihood and prior 
unstd.posterior3 <- likelihood3 * newprior
# standardize posterior 
posterior3 <- unstd.posterior3/sum(unstd.posterior3)
# plot 
plot(p_grid, posterior3, type = "b", 
     xlab = "probability of water", ylab = "posterior probability")

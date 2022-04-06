# Packages ------------------------------------
library(rethinking)

# King Markov ---------------------------------
num_weeks <- 1e5
positions <- rep(0, num_weeks)
current <- 10
for(i in 1:num_weeks){
  # record current position 
  positions[i] <- current 
  # flip coin 
  proposal <- current + sample(c(-1,1), size =1)
  # loop the archipelago
  if (proposal < 1) proposal <- 10
  if (proposal > 10) proposal <- 1
  # move
  prob_move <- proposal/current 
  current <- ifelse(runif(1) < prob_move, proposal, current)
}
plot(table(positions))

# Hamiltonian Monte Carlo ---------------------
rm(list=ls())
data(rugged)
d <- rugged
d$log_gdp <- log(d$rgdppc_2000)
dd <- d[complete.cases(d$rgdppc_2000), ]
dd$log_gdp_std <- dd$log_gdp/mean(dd$log_gdp)
dd$rugged_std <- dd$rugged/max(dd$rugged)
dd$cid <- ifelse(dd$cont_africa==1, 1, 2)

m8.3 <- quap(alist(
  log_gdp_std ~ dnorm(mu, sigma),
  mu <- a[cid] + b[cid]*(rugged_std-0.215),
  a[cid] ~ dnorm(1, 0.1), 
  b[cid] ~ dnorm(0, 0.3),
  sigma ~ dexp(1)
), data = dd)

dat_slim <- list(log_gdp_std = dd$log_gdp_std,
                 rugged_std = dd$rugged_std,
                 cid = as.integer(dd$cid))

m9.1 <- ulam(alist(
  log_gdp_std ~ dnorm(mu, sigma),
  mu <- a[cid] + b[cid]*(rugged_std-0.215),
  a[cid] ~ dnorm(1, 0.1), 
  b[cid] ~ dnorm(0, 0.3),
  sigma ~ dexp(1)
), data = dat_slim, chains =4, cores =4)

pairs(m9.1)
traceplot(m9.1)
trankplot(m9.1)

# Diagnosing Bad Models --------------------
rm(list=ls())
y <- c(-1,1)
set.seed(11)
m9.2 <- ulam(alist(
  y ~ dnorm(mu, sigma),
  mu <- alpha, 
  alpha ~ dnorm(0, 1000),
  sigma ~ dexp(0.0001)
), data = list(y=y), chains=3)
pairs(m9.2@stanfit)
traceplot(m9.2)
trankplot(m9.2)
# tame model by adding weakly informative priors
m9.3 <- ulam(alist(
  y ~ dnorm(mu, sigma),
  mu <- alpha, 
  alpha ~ dnorm(0, 10),
  sigma ~ dexp(1)
), data = list(y=y), chains=3)

# Non-Identifiable Parameters ---------------
rm(list=ls())
set.seed(41)
y <- rnorm(100, mean=0, sd=1)
set.seed(384)
m9.4 <- ulam(alist(
  y ~ dnorm(mu, sigma),
  mu <- a1 + a2, 
  a1 ~ dnorm(0, 1000),
  a2 ~ dnorm(0, 1000),
  sigma ~ dexp(1)
), data = list(y=y), chains=3)
# use weak priors 
m9.5 <- ulam(alist(
  y ~ dnorm(mu, sigma),
  mu <- a1 + a2, 
  a1 ~ dnorm(0, 10),
  a2 ~ dnorm(0, 10),
  sigma ~ dexp(1)
), data = list(y=y), chains=3)

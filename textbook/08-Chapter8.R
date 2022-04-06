# Packages -----------------------------------------
library(rethinking)

# Data ---------------------------------------------
data(rugged)
d <- rugged
# log outcome 
d$log_gdp <- log(d$rgdppc_2000)
# extract countries with GDP data 
dd <- d[complete.cases(d$rgdppc_2000), ]
# rescale 
dd$log_gdp_std <- dd$log_gdp / mean(dd$log_gdp) # mean is 1
dd$rugged_std <- dd$rugged / max(dd$rugged)

# Model ----------------------------------------------
m8.1 <- quap(
  alist(
    log_gdp_std ~ dnorm(mu, sigma),
    mu <- a + b*(rugged_std - 0.215),
    a ~ dnorm(1, 0.1),
    b ~ dnorm(0, 0.3),
    sigma ~ dexp(1)
  ), data = dd
)
# look at prior predictions 
set.seed(7)
prior <- extract.prior(m8.1)
plot(NULL, xlim=c(0,1), ylim=c(0.5,1.5),
     xlab="ruggedness", ylab="log GDP")
abline(h=min(dd$log_gdp_std), lty=2)
abline(h=max(dd$log_gdp_std), lty=2)
# draw 50 lines from the prior
rugged_seq <- seq(from=-0.1, to=1.1, length.out=30)
mu <- link(m8.1, post=prior, data = data.frame(rugged_std=rugged_seq))
for (i in 1:50) lines(rugged_seq, mu[i,], col=col.alpha("black", 0.3))
# model summary
precis(m8.1)

# Conditional Intercept ----------------------------------
# make variable to index Africa (1) or not (2)
dd$cid <- ifelse(dd$cont_africa==1, 1, 2)

m8.2 <- quap(alist(
  log_gdp_std ~ dnorm(mu, sigma),
  mu <- a[cid] + b*(rugged_std - 0.215),
  a[cid] ~ dnorm(1, 0.1),
  b ~ dnorm(0, 0.3),
  sigma ~ dexp(1)
), data = dd)

compare(m8.1, m8.2)
precis(m8.2, depth = 2)
# posterior contrast 
post <- extract.samples(m8.2)
diff_a1_a2 <- post$a[,1] - post$a[,2]
PI(diff_a1_a2)
# compute predicted means and intervals for African and Non-African nations 
rugged.seq <- seq(from=-0.1, to=1.1, length.out=30)
# compute mu over samples 
mu.NotAfrica <- link(m8.2, data = data.frame(cid=2, rugged_std=rugged.seq))
mu.Africa <- link(m8.2, data = data.frame(cid=1, rugged_std = rugged.seq))
# summarize means and intervals 
mu.NotAfrica_mu <- apply(mu.NotAfrica, 2, mean)
mu.NotAfrica_ci <- apply(mu.NotAfrica, 2, PI, prob = 0.97)
mu.Africa_mu <- apply(mu.Africa, 2, mean)
mu.Africa_ci <- apply(mu.Africa, 2, PI, prob = 0.97)

# Conditional Slope ------------------------------------
# need a proper interaction term to have slope vary conditionally, not just intercept 
m8.3 <- quap(alist(
  log_gdp_std ~ dnorm(mu, sigma),
  mu <- a[cid] + b[cid]*(rugged_std-0.215),
  a[cid] ~ dnorm(1, 0.1), 
  b[cid] ~ dnorm(0, 0.3),
  sigma ~ dexp(1)
), data = dd)
precis(m8.3, depth = 2)
compare(m8.1, m8.2, m8.3, func=PSIS)
plot(PSIS(m8.3, pointwise = T)$k)
# plot Africa 
d.A1 <- dd[dd$cid==1, ]
plot(d.A1$rugged_std, d.A1$log_gdp_std)
mu <- link(m8.3, data = data.frame(cid=1, rugged_std = rugged_seq))
mu_mean <- apply(mu, 2, mean)
mu_ci <- apply(mu, 2, PI, prob = 0.97)
lines(rugged_seq, mu_mean, lwd=2)
shade(mu_ci, rugged_seq, col=col.alpha(rangi2, 0.3))
# plot Non-Africa
d.A0 <- dd[dd$cid==2, ]
plot(d.A0$rugged_std, d.A0$log_gdp_std)
mu <- link(m8.3, data = data.frame(cid=2, rugged_std = rugged_seq))
mu_mean <- apply(mu, 2, mean)
mu_ci <- apply(mu, 2, PI, prob = 0.97)
lines(rugged_seq, mu_mean, lwd=2)
shade(mu_ci, rugged_seq, col=col.alpha(rangi2, 0.3))

# compute difference in GDP inside and outside Africa, holding ruggedness constant 
# by running link and subtracting difference 
# examining model comparisons - not data 
rugged_seq <- seq(from=-0.2, to=1.2, length.out=30)
muA <- link(m8.3, data=data.frame(cid=1, rugged_std=rugged_seq))
muN <- link(m8.3, data=data.frame(cid=2, rugged_std=rugged_seq))
delta <- muA - muN

# Continuous Interactions -----------------------------
rm(list=ls())
data(tulips)
d <- tulips 
d$blooms_std <- d$blooms / max(d$blooms)
d$water_cent <- d$water - mean(d$water)
d$shade_cent <- d$shade - mean(d$shade)

m8.4 <- quap(
  alist(
    blooms_std ~ dnorm(mu, sigma),
    mu <- a + bw*water_cent + bs*shade_cent,
    a ~ dnorm(0.5, 0.25),
    bw ~ dnorm(0, 0.25),
    bs ~ dnorm(0, 0.25),
    sigma ~ dexp(1)
  ), data = d
)

m8.5 <- quap(
  alist(
    blooms_std ~ dnorm(mu, sigma),
    mu <- a + bw*water_cent + bs*shade_cent + bws*water_cent*shade_cent,
    a ~ dnorm(0.5, 0.25),
    bw ~ dnorm(0, 0.25),
    bs ~ dnorm(0, 0.25),
    bws ~ dnorm(0, 0.25),
    sigma ~ dexp(1)
  ), data = d
)

# plot 
par(mfrow=c(1,3))
for(s in -1:1){
  idx <- which(d$shade_cent==s)
  plot(d$water_cent[idx], d$blooms_std[idx], xlim=c(-1,1), ylim=c(0,1),
       xlab="water", ylab="blooms", pch=16, col=rangi2)
  mu <- link(m8.4, data = data.frame(shade_cent=s, water_cent=-1:1))
  for(i in 1:20) lines(-1:1, mu[i,], col=col.alpha("black", 0.3))
}

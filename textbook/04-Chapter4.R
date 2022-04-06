library(rethinking)

#### Coin Toss Example - Random by Addition ####
# 1000 replicates of 16 individuals flipping a coin and taking a step forward (1) for tails and backwards (-1) for heads
pos <- replicate( 1000 , sum( runif(16,-1,1) ) )
# visualize the normal distribution
hist(pos)
plot(density(pos))


#### Growth Rate Example - Random by Multiplication #### 
# sample a random growth rate between 1.0 and 1.1 
prod( 1 + runif(12,0,0.1) )
# generate 10,000 of these 
growth <- replicate( 10000 , prod( 1 + runif(12,0,0.1) ) )
# plot distribution
plot(density( growth , norm.comp=TRUE ))
# small changes fit a Gaussian distribution better when multiplying 
big <- replicate( 10000 , prod( 1 + runif(12,0,0.5) ) )
small <- replicate( 10000 , prod( 1 + runif(12,0,0.01) ) )
plot(density(big)) # left skewed 
plot(density(small)) # normal
# large effect sizes become normal when on a log scale 
log.big <- replicate( 10000 , log(prod(1 + runif(12,0,0.5))) )
plot(density(log.big))


#### Gaussian Model of Height ####
# load Howell dataset
data(Howell1)
d <- Howell1
# summarize with precis 
precis( d )
# subset adults 
d2 <- d[ d$age >= 18 , ]
# plot priors to see dist 
# mu is 178 cm +/- 40 cm
curve( dnorm( x , 178 , 20 ) , from=100 , to=250 )
# sigma is flat curve from 0,50
curve( dunif( x , 0 , 50 ) , from=-10 , to=60 )
# do a prior predictive simulation to test prior performance 
sample_mu <- rnorm( 1e4 , 178 , 20 )
sample_sigma <- runif( 1e4 , 0 , 50 )
prior_h <- rnorm( 1e4 , sample_mu , sample_sigma )
dens( prior_h )
# view expected heights based on priors 
prior_h <- rnorm( 1e4 , sample_mu , sample_sigma )
dens( prior_h )

# execute model and calculate posterior using grid approximation 
mu.list <- seq( from=150, to=160 , length.out=100 )
sigma.list <- seq( from=7 , to=9 , length.out=100 )
post <- expand.grid( mu=mu.list , sigma=sigma.list )
post$LL <- sapply( 1:nrow(post) , function(i) sum(
  dnorm( d2$height , post$mu[i] , post$sigma[i] , log=TRUE ) ) )
post$prod <- post$LL + dnorm( post$mu , 178 , 20 , TRUE ) +
  dunif( post$sigma , 0 , 50 , TRUE )
post$prob <- exp( post$prod - max(post$prod) )
# plot
contour_xyz( post$mu , post$sigma , post$prob )
image_xyz( post$mu , post$sigma , post$prob )

# sample the posterior - need to sample combinations of parameters since there is more than 1
sample.rows <- sample( 1:nrow(post) , size=1e4 , replace=TRUE, prob=post$prob )
sample.mu <- post$mu[ sample.rows ]
sample.sigma <- post$sigma[ sample.rows ]
# plot 
plot( sample.mu , sample.sigma , cex=0.5 , pch=16 , col=col.alpha(rangi2,0.1) )
# describe the samples
dens( sample.mu )
dens( sample.sigma )
# get compatibility intervals 
PI( sample.mu )
PI( sample.sigma )

# test with small sample size 
d3 <- sample( d2$height , size=20 )
mu.list <- seq( from=150, to=170 , length.out=200 )
sigma.list <- seq( from=4 , to=20 , length.out=200 )
post2 <- expand.grid( mu=mu.list , sigma=sigma.list )
post2$LL <- sapply( 1:nrow(post2) , function(i)
  sum( dnorm( d3 , mean=post2$mu[i] , sd=post2$sigma[i] ,
              log=TRUE ) ) )
post2$prod <- post2$LL + dnorm( post2$mu , 178 , 20 , TRUE ) +
  dunif( post2$sigma , 0 , 50 , TRUE )
post2$prob <- exp( post2$prod - max(post2$prod) )
sample2.rows <- sample( 1:nrow(post2) , size=1e4 , replace=TRUE ,
                        prob=post2$prob )
sample2.mu <- post2$mu[ sample2.rows ]
sample2.sigma <- post2$sigma[ sample2.rows ]
plot( sample2.mu , sample2.sigma , cex=0.5 ,
      col=col.alpha(rangi2,0.1) ,
      xlab="mu" , ylab="sigma" , pch=16 )
dens( sample2.sigma , norm.comp=TRUE )


#### Quadratic Approximation #### 
data(Howell1)
d <- Howell1
d2 <- d[ d$age >= 18 , ]
# define the model in a list 
flist <- alist(
  height ~ dnorm( mu , sigma ) ,
  mu ~ dnorm( 178 , 20 ) ,
  sigma ~ dunif( 0 , 50 )
)
# fit model to data using quadratic approximation 
m4.1 <- quap( flist , data=d2 )
# look at post. dist.
precis(m4.1)

# can specify starting point for quap (default is randomly selected mu/sigma)
start <- list(
  mu=mean(d2$height),
  sigma=sd(d2$height)
)
m4.1 <- quap( flist , data=d2 , start=start )

# specify a narrower prior (std. dev. = 0.1 instead of 20 this time)
m4.2 <- quap(
  alist(
    height ~ dnorm( mu , sigma ) ,
    mu ~ dnorm( 178 , 0.1 ) ,
    sigma ~ dunif( 0 , 50 )
  ) , data=d2 )
precis( m4.2 )

# view variance-covariance matrix of the quadratic approximation 
vcov(m4.1)
diag( vcov( m4.1 )) # list of variances
cov2cor( vcov( m4.1 ) ) # correlation matrix

# extract samples from posterior multi-dimensional Gaussian distribution 
post <- extract.samples( m4.1 , n=1e4 )
head(post)
precis(post)


#### Linear Prediction #### 
d <- data(Howell1)
d <- Howell1
d2 <- d[Howell1$age >= 18, ]
plot( d2$height ~ d2$weight )
# simulate heights using weight data + priors 
set.seed(2971) # setting seed so it is reproducible 
N <- 100 # 100 lines
a <- rnorm( N , 178 , 20 )
b <- rnorm( N , 0 , 10 )
# plot simulated data with sampled alpha and beta + weight dataset
plot( NULL , xlim=range(d2$weight) , ylim=c(-100,400), 
      xlab="weight" , ylab="height" )
abline( h=0 , lty=2 )
abline( h=272 , lty=1 , lwd=0.5 )
mtext( "b ~ dnorm(0,10)" )
xbar <- mean(d2$weight)
for ( i in 1:N ) curve( a[i] + b[i]*(x - xbar),
                        from=min(d2$weight) , to=max(d2$weight) , add=TRUE ,
                        col=col.alpha("black",0.2) )

# set beta to log-normal distribution to restrict to positive values
b <- rlnorm( 1e4 , 0 ,1)
dens( b , xlim=c(0,5) , adj=0.1 )
# redo simulation 
set.seed(2971)
N <- 100 # 100 lines
a <- rnorm( N , 178 , 20 )
b <- rlnorm( N , 0 , 1 )
plot( NULL , xlim=range(d2$weight) , ylim=c(-100,400), 
      xlab="weight" , ylab="height" )
abline( h=0 , lty=2 )
abline( h=272 , lty=1 , lwd=0.5 )
mtext( "b ~ dnorm(0,10)" )
xbar <- mean(d2$weight)
for ( i in 1:N ) curve( a[i] + b[i]*(x - xbar),
                        from=min(d2$weight) , to=max(d2$weight) , add=TRUE ,
                        col=col.alpha("black",0.2) )
# define model with new priors 
xbar <- mean(d2$weight)
m4.3 <- quap(
  alist(
    height ~ dnorm( mu , sigma ) ,
    mu <- a + b*( weight - xbar ) ,
    a ~ dnorm( 178 , 20 ) ,
    b ~ dlnorm( 0 , 1 ) ,
    sigma ~ dunif( 0 , 50 )
  ) , data=d2 )
# summarize the posterior distribution 
precis(m4.3) # marginal distribution table 
round( vcov( m4.3 ) , 3 ) # variance-covariance matrix 
# plot posterior distribution with raw data 
plot( height ~ weight , data=d2 , col=rangi2 )
post <- extract.samples( m4.3 )
a_map <- mean(post$a)
b_map <- mean(post$b)
curve( a_map + b_map*(x - xbar) , add=TRUE )

# redo model and incorporate uncertainty into posterior plot 
N <- 100
dN <- d2[ 1:N , ]
mN <- quap(
    alist(
      height ~ dnorm( mu , sigma ) ,
      mu <- a + b*( weight - mean(weight) ) ,
      a ~ dnorm( 178 , 20 ) ,
      b ~ dlnorm( 0 , 1 ) ,
      sigma ~ dunif( 0 , 50 )
    ) , data=dN )
post <- extract.samples( mN , n=20 )
plot( dN$weight , dN$height ,
      xlim=range(d2$weight) , ylim=range(d2$height) ,
      col=rangi2 , xlab='weight', ylab="height" )

mtext(concat("N = ",N))
for ( i in 1:20 ) curve( post$a[i] + post$b[i]*(x-mean(dN$weight)) ,
         col=col.alpha("black",0.3) , add=TRUE )

# plotting regression contours 
post <- extract.samples( m4.3 )
mu_at_50 <- post$a + post$b * ( 50 - xbar ) # want samples at 50 kg
dens( mu_at_50 , col=rangi2 , lwd=2 , xlab="mu|weight=50" )
PI( mu_at_50 , prob=0.89 ) # get 89% PI
# do this for all weight values 
mu <- link( m4.3 )
# define sequence of weights to compute predictions for these values will be on the horizontal axis
weight.seq <- seq( from=25 , to=70 , by=1 )
# use link to compute mu for each sample from posterior and for each weight in weight.seq
mu <- link( m4.3 , data=data.frame(weight=weight.seq) )
# use type=“n” to hide raw data
plot( height ~ weight , d2 , type="n")
# loop over samples and plot each mu value
for ( i in 1:100 ) points( weight.seq , mu[i,] , pch=16 , col=col.alpha(rangi2,0.1) )
# summarize the distribution of mu
mu.mean <- apply( mu , 2 , mean )
mu.PI <- apply( mu , 2 , PI , prob=0.89 )
# plot raw data
# fading out points to make line and interval more visible
plot( height ~ weight , data=d2 , col=col.alpha(rangi2,0.5) )
# plot the MAP line, aka the mean mu for each weight
lines( weight.seq , mu.mean )
# plot a shaded region for 89% PI
shade( mu.PI , weight.seq )

# simulate height 
sim.height <- sim( m4.3 , data=list(weight=weight.seq) )
str(sim.height)
height.PI <- apply( sim.height , 2 , PI , prob=0.89 ) # get 89% PIs across simulated heights
plot( height ~ weight , d2 , col=col.alpha(rangi2,0.5) )
lines( weight.seq , mu.mean ) #MAP line
shade( mu.PI , weight.seq ) # draw PI region for line
shade( height.PI , weight.seq ) # draw PI region for simulated heights

## NOTE: bring up this figure in meeting - not quite understanding

#### Polynomial Regression #### 
data(Howell1)
d <- Howell1
plot(height ~ weight, data = d)
d$weight_s <- ( d$weight - mean(d$weight) )/sd(d$weight)  # transform variables before modelling
d$weight_s2 <- d$weight_s^2
m4.5 <- quap(
  alist(
    height ~ dnorm( mu , sigma ) ,
    mu <- a + b1*weight_s + b2*weight_s2 ,
    a ~ dnorm( 178 , 20 ) ,
    b1 ~ dlnorm( 0 , 1) ,
    b2 ~ dnorm( 0 , 1 ) ,
    sigma ~ dunif( 0 , 50 )
  ) , data=d )
precis(m4.5)
# calculate the mean relationship and the 89% intervals of the mean and the predictions
weight.seq <- seq( from=-2.2 , to=2 , length.out=30 )
pred_dat <- list( weight_s=weight.seq , weight_s2=weight.seq^2 )
mu <- link( m4.5 , data=pred_dat )
mu.mean <- apply( mu , 2 , mean )
mu.PI <- apply( mu , 2 , PI , prob=0.89 )
sim.height <- sim( m4.5 , data=pred_dat )
height.PI <- apply( sim.height , 2 , PI , prob=0.89 )

plot( height ~ weight_s , d , col=col.alpha(rangi2,0.5) )
lines( weight.seq , mu.mean )
shade( mu.PI , weight.seq )
shade( height.PI , weight.seq )

# change to cubic relationship with slight change to code
d$weight_s3 <- d$weight_s^3
m4.6 <- quap(
  alist(
    height ~ dnorm( mu , sigma ) ,
    mu <- a + b1*weight_s + b2*weight_s2 + b3*weight_s3 ,
    a ~ dnorm( 178 , 20 ) ,
    b1 ~ dlnorm( 0 , 1 ) ,
    b2 ~ dnorm( 0 , 10 ) ,
    b3 ~ dnorm( 0 , 10 ) ,
    sigma ~ dunif( 0 , 50 )
  ) , data=d )


#### B-Splines ####
data(cherry_blossoms)
d <- cherry_blossoms
precis(d)
plot(doy ~ year, d)


d2 <- d[ complete.cases(d$doy) , ] # complete cases on doy
num_knots <- 15
knot_list <- quantile( d2$year , probs=seq(0,1,length.out=num_knots) )

library(splines)
B <- bs(d2$year,
        knots=knot_list[-c(1,num_knots)] ,
        degree=3 , intercept=TRUE ) # degree = 3, cubic polynomial
# each row is a year, each column is a basis function
# plot basis functions 
plot( NULL , xlim=range(d2$year) , ylim=c(0,1) , xlab = "year" , ylab = "basis" )
for ( i in 1:ncol(B) ) lines( d2$year , B[,i] )

m4.7 <- quap(
  alist(
    D ~ dnorm( mu , sigma ) ,
    mu <- a + B %*% w , # matrix multiplication to include the summing of basis functions
    a ~ dnorm(100,10),
    w ~ dnorm(0,10),
    sigma ~ dexp(1)
  ), data=list( D=d2$doy , B=B ) ,
  start=list( w=rep( 0 , ncol(B) ) ) ) # use start list for the weights
# weighted basis functions 
post <- extract.samples( m4.7 )
w <- apply( post$w , 2 , mean )
plot( NULL , xlim=range(d2$year) , ylim=c(-6,6) ,
      xlab="year" , ylab="basis * weight" )
for ( i in 1:ncol(B) ) lines( d2$year , w[i]*B[,i] )
# 97 % posterior intervals for mu at each year
mu <- link( m4.7 )
mu_PI <- apply(mu,2,PI,0.97)
plot( d2$year , d2$doy , col=col.alpha(rangi2,0.3) , pch=16)
shade( mu_PI , d2$year , col=col.alpha("black",0.5) ) 

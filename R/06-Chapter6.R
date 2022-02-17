#### Selection-Distortion Effect ####
set.seed(1914)
N <- 200 # grant proposals 
p <- 0.1 # proportion to select 
nw <- rnorm(N) # newsworthiness (not correlated with trustworthiness)
tw <- rnorm(N) # trustworthiness (not correlated with newsworthiness)
# select top 10% of combined scores 
s <- nw + tw # total score 
q <- quantile(s, 1-p) # top 10% threshold 
selected <- ifelse(s >= q, TRUE, FALSE)
cor(tw[selected], nw[selected])

#### Multicollinearity ####
# Leg-Height Example 
library(rethinking)
N <- 100 
set.seed(909)

height <- rnorm(N, 10, 2) # sim total height 
leg_prop <- runif(N, 0.4, 0.5) # leg as proportion of height 
leg_left <- leg_prop*height + rnorm(N, 0, 0.2) # sim left leg as proportion + error 
leg_right <- leg_prop*height + rnorm(N, 0, 0.2)

d <- data.frame(height, leg_left, leg_right)

ml <- quap(
  alist(
    height ~ dnorm(mu, sigma),
    mu <- a + bl*leg_left + br*leg_right,
    a ~ dnorm(10,100),
    bl ~ dnorm(2, 10),
    br ~ dnorm(2, 10),
    sigma ~ dexp(1)
  ), data = d)

plot(precis(ml))

post <- extract.samples(ml)
plot(bl ~ br, post, col = col.alpha(rangi2, 0.1), pch = 16)

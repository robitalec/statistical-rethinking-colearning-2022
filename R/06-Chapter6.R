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
plot(bl ~ br, post, col = col.alpha(rangi2, 0.1), pch = 16) # 

# plot sum of beta left leg + beta right leg 
sum_blbr <- post$bl + post$br
dens(sum_blbr, col = rangi2, lwd = 2, xlab = "sum of bl and br")
# posterior mean is ~ 2 

# fit regression with only one leg length variables 
m6.2 <- quap(
  alist(
    height ~ dnorm(mu, sigma),
    mu <- a + bl*leg_left,
    a ~ dnorm(10, 100),
    bl ~ dnorm(2, 10),
    sigma ~ dexp(1)
  ), data = d
)
precis(m6.2)
# posterior mean is approximately the same as the sum of bl + br


#### Milk Multicollinerity #### 
rm(list=ls())
data(milk)
d <- milk
d$K <- standardize(d$kcal.per.g)
d$F <- standardize(d$perc.fat)
d$L <- standardize(d$perc.lactose)

m6.3 <- quap(
  alist(
    K ~ dnorm(mu, sigma),
    mu <- a + bF*F, 
    a ~ dnorm(0, 0.2),
    bF ~ dnorm(0, 0.5),
    sigma ~ dexp(1)
  ), data = d
)

m6.4 <- quap(
  alist(
    K ~ dnorm(mu, sigma),
    mu <- a + bL*L, 
    a ~ dnorm(0, 0.2),
    bL ~ dnorm(0, 0.5),
    sigma ~ dexp(1)
  ), data = d
)

precis(m6.3)
precis(m6.4)
# posterior distributions are mirror images - with strong associations with total energy in milk 
# include both in the same model 
m6.5 <- quap(
  alist(
    K ~ dnorm(mu, sigma),
    mu <- a + bL*L + bF*F, 
    a ~ dnorm(0, 0.2),
    bL ~ dnorm(0, 0.5),
    bF ~ dnorm(0, 0.5),
    sigma ~ dexp(1)
  ), data = d
)
precis(m6.5) # mean estimates are closer to zero and sd are much larger when both are in model 
# effect is minimized because variables are correlated and not adding info to the model
pairs(~ kcal.per.g + perc.fat + perc.lactose, data = d, col = rangi2)


#### Post Treatment Bias ####
rm(list = ls())
set.seed(71)
N <- 100
h0 <- rnorm(N, 10, 2) # initial heights
# assign treatments and simulate fungus and growth 
treatment <- rep(0:1, each = N/2)
fungus <- rbinom(N, size = 1, prob = 0.5 - treatment*0.4)
h1 <- h0 + rnorm(N, 5-3*fungus)
# clean dataframe 
d <- data.frame(h0=h0, h1=h1, treatment=treatment, fungus=fungus)
precis(d)

# assign prior to growth variable - p = h1 / h0 (height at end of experiment/initial height)
# p > 0 because it is a proportion. p = 1 means no growth, p < 1 means shrinkage, p = 2 means doubling in height 
sim_p <- rlnorm(1e4, 0, 0.25)
m6.6 <- quap(
  alist(
    h1 ~ dnorm(mu, sigma), 
    mu <- h0*p,
    p ~ dlnorm(0, 0.25),
    sigma ~ dexp(1)
  ), data = d
)
precis(m6.6)
# add treatment and growth to the proportion growth variable 
m6.7 <- quap(alist(
  h1 ~ dnorm(mu,sigma),
  mu <- h0*p,
  p <- a + bt*treatment + bf*fungus,
  a ~ dlnorm(0, 0.2), # same as p in m6.6
  bt ~ dnorm(0,0.5),
  bf ~ dnorm(0,0.5),
  sigma ~ dexp(1)
), data = d)
precis(m6.7)
# treatment shows no effect but fungus shows negative effect 
# treatment has an effect but through fungus so when fungus is added to the model, there is no ADDITIONAL effect of treatment 

# to test effect of treatment on growth, omit fungus 
m6.8 <- quap(alist(
  h1 ~ dnorm(mu,sigma),
  mu <- h0*p,
  p <- a + bt*treatment,
  a ~ dlnorm(0, 0.2), # same as p in m6.6
  bt ~ dnorm(0,0.5),
  sigma ~ dexp(1)
), data = d)
precis(m6.8)
# now we see effect of treatment 

library(dagitty)
plant_dag <- dagitty("dag { 
                     h_0 -> h_1
                     f -> h_1
                     t -> f
                  }")
coordinates(plant_dag) <- list(x = c(h_0=0, T=2, F=1.5, h_1=1), 
                               y = c(h_0=0, T=0, F=0, h_1=0))
drawdag(plant_dag)
impliedConditionalIndependencies(plant_dag)


#### Collider Bias ####
rm(list = ls())
# happiness simulation 
d <- sim_happiness()
precis(d)

d2 <- d[d$age > 17, ]
d2$A <- (d2$age - 18) / (65 - 18) # rescale so age is one unit 
d2$mid <- d2$married + 1 # recode categorical variable 
m6.9 <- quap(
  alist(
    happiness ~ dnorm(mu, sigma),
    mu <- a[mid] + bA*A,
    a[mid] ~ dnorm(0,1),
    bA ~ dnorm(0,2),
    sigma ~ dexp(1)
  ), data = d2
)
precis(m6.9, depth=2)
# age is negatively associated with happiness because of collider bias 
# remove marriage status from model and this collider bias disappears and there is no relationship
m6.10 <- quap(
  alist(
    happiness ~ dnorm(mu, sigma),
    mu <- a + bA*A,
    a ~ dnorm(0,1),
    bA ~ dnorm(0,2),
    sigma ~ dexp(1)
  ), data = d2
)
precis(m6.10, depth=2)


# haunted DAG 
N <- 200 
b_GP <- 1 # direct effect of G on P 
b_GC <- 0 # direct effect of G on C
b_PC <- 1 # direct effect of P on C 
b_U <- 2 # direct effect of U on P and C 
set.seed(1)
U <- 2*rbern(N, 0.5) - 1
G <- rnorm(N)
P <- rnorm(N, b_GP*G + b_U*U)
C <- rnorm(N, b_PC*P + b_GC*G + b_U*U)
d <- data.frame(C=C, P=P, G=G, U=U)
m6.11 <- quap(
  alist(
    C ~ dnorm(mu, sigma), 
    mu <- a + b_PC*P + b_GC*G,
    a ~ dnorm(0, 1),
    c(b_PC, b_GC) ~ dnorm(0, 1), 
    sigma ~ dexp(1)
  ), data = d
)
precis(m6.11)

# measure the unknown variable producing the collider bias and the effect disappears 
m6.12 <- quap(
  alist(
    C ~ dnorm(mu, sigma), 
    mu <- a + b_PC*P + b_GC*G + b_U*U,
    a ~ dnorm(0, 1),
    c(b_PC, b_GC, b_U) ~ dnorm(0, 1), 
    sigma ~ dexp(1)
  ), data = d
)
precis(m6.12)


#### Confounding Effects ####
# automate finding backdoor paths and confounders 
rm(list = ls())
dag6.1 <- dagitty("dag {
                  U [unobserved]
                  X -> Y
                  X <- U <- A -> C -> Y
                  U -> B <- C }")
adjustmentSets(dag6.1, exposure = "X", outcome = "Y")

dag6.2 <- dagitty("dag {
                  A -> D
                  A -> M -> D 
                  A <- S -> M 
                  S -> W -> D }")
adjustmentSets(dag6.2, exposure = "W", outcome = "D")
impliedConditionalIndependencies(dag6.2)

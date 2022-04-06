
# Packages ----------------------------------------------------------------

library(rethinking)


# Data --------------------------------------------------------------------

data("chimpanzees")
d <- chimpanzees

d$treatment <- 1 + d$prosoc_left + 2*d$condition
# verify
xtabs(~ treatment + prosoc_left + condition, d)

# Model -------------------------------------------------------------------

m11.1 <- quap(
  alist(
    pulled_left ~ dbinom(1,p),
    logit(p) <- a,
    a ~ dnorm(0, 1.5)
  ), data = d
)

# sample from prior 
set.seed(1999)
prior <- extract.prior(m11.1, n=1e4)
# convert parameter to outcome scale 
p <- inv_logit(prior$a)
dens(p, adj = 0.1)

m11.2 <- quap(
  alist(
    pulled_left ~ dbinom(1, p),
    logit(p) <- a + b[treatment],
    a ~ dnorm(0, 1.5),
    b[treatment] ~ dnorm(0,0.5)
  ), data = d
)
set.seed(1999)
prior <- extract.prior(m11.2, n=1e4)
p <- sapply(2:4, function(k) inv_logit(prior$a + prior$b[,k]))
dens(abs(p[,1] - p[,2]), adj=0.1)


# Logistic MCMC ----------------------------------------------------------


dat_list <- list(
  pulled_left = d$pulled_left, 
  actor = d$actor, 
  treatment = as.integer(d$treatment)
)

m11.4 <- ulam(
  alist(
    pulled_left ~ dbinom(1, p),
    logit(p) <- a[actor] + b[treatment],
    a[actor] ~ dnorm(0, 1.5),
    b[treatment] ~ dnorm(0, 0.5)
  ), data = dat_list, chains = 4, log_lik = TRUE
)
precis(m11.4, depth = 2)

post <- extract.samples(m11.4)
p_left <- inv_logit(post$a)
plot(precis(as.data.frame(p_left)), xlim=c(0,1))

# investigate treatment effects 
labs <- c("R/N", "L/N", "R/P", "L/P")
plot(precis(m11.4, depth = 2, pars = 'b'), labels = labs)
# look at differences for right and left sides 
diffs <- list(db13 = post$b[,1] - post$b[,3],
              db24 = post$b[,2] - post$b[,4])
plot(precis(diffs))

# posterior prediction check 
pl <- by(d$pulled_left, list(d$actor, d$treatment), mean)
pl[1,]

d$side <- d$prosoc_left + 1 # right 1, left 2
d$cond <- d$condition + 1 # no partner 1, partner 2

dat_list2 <- list(
  pulled_left = d$pulled_left,
  actor = d$actor,
  side = d$side,
  cond = d$cond
)

m11.5 <- ulam(
  alist(
    pulled_left ~ dbinom(1, p),
    logit(p) <- a[actor] + bs[side] + bc[cond],
    a[actor] ~ dnorm(0, 1.5),
    bs[side] ~ dnorm(0, 0.5),
    bc[cond] ~ dnorm(0, 0.5)
  ), data = dat_list2, chains = 4, log_lik = T)

compare(m11.5, m11.4, func=PSIS)

# calculate relative effect of switching from treatment 2 to treatment 4 
post <- extract.samples(m11.4)
mean(exp(post$b[,4]-post$b[,2]))


# Aggregated MCMC ---------------------------------------------------------

rm(list=ls())

data(chimpanzees)
d <- chimpanzees
d$treatment <- 1 + d$prosoc_left + 2*d$condition
d$side <- d$prosoc_left + 1 # right 1, left 2
d$cond <- d$condition + 1 # no partner 1, partner 2

d_aggregated <- aggregate(
  d$pulled_left,
  list(treatment=d$treatment, actor = d$actor, side = d$side, cond = d$cond), sum)
col_names(d_aggregated)[5] <- "left_pulls"

dat <- with(d_aggregated, list(left_pulls = left_pulls, treatment = treatment, actor = actor, side = side, cond = cond))

m11.6 <- ulam(
  alist(
    pulled_left ~ dbinom(18, p),
    logit(p) <- a[actor] + b[treatment],
    a[actor] ~ dnorm(0, 1.5),
    b[treatment] ~ dnorm(0, 0.5)
  ), data = dat_list2, chains = 4, log_lik = T)

compare(m11.6, m11.4, func=PSIS)


# Aggregated Graduate Apps ------------------------------------------------


rm(list=ls())
data("UCBAdmissions")
d <- UCBAdmissions

dat_list <- list(
  admit = d$admit, 
  applications = d$applications, 
  gid = ifelse(d$applicant.gender == "male", 1, 2)
)

m11.7 <- ulam(alist(
  admit ~ dbinom(applications, p),
  logit(p) <- a[gid],
  a[gid] ~ dnorm(0, 1.5)
), data = dat_list, chains = 4)
precis(m11.7, depth = 2)

post <- extract.samples(m11.7)
diff_a <- post$a[,1] - post$a[,2]
diff_p <- inv_logit(post$a[,1]) - inv_logit(post$a[,2])
precis(list(diff_a=diff_a, diff_p = diff_p))

postcheck(m11.7)

# need to check this phenomenon within departments 
dat_list$dept_id <- rep(1:6, each = 2)
m11.8 <- ulam(
  alist(
    admit ~ dbinom(applications, p),
    logit(p) <- a[gid] + delta[dept_id],
    a[gid] ~ dnorm(0, 1.5),
    delta[dept_id] ~ dnorm(0, 1.5)
  ), data = dat_list, chains = 4, iter = 4000
)
precis(m11.8, depth = 2)

post <- extract.samples(m11.8)
diff_a <- post$a[,1] - post$a[,2]
diff_p <- inv_logit(post$a[,1]) - inv_logit(post$a[,2])
precis(list(diff_a = diff_a, diff_p = diff_p))

pg <- with(dat_list, sapply(1:6, function(k)
  applications[dept_id==k]/sum(applications[dept_id==k])))
rownames(pg) <- c("male", "female")
colnames(pg) <- unique(d$dept)
round(pg, 2)


# Poisson -----------------------------------------------------------------

data(Kline)
d <- Kline

d$P <- scale(log(d$population))
d$contact_id <- ifelse(d$contact=='high', 2, 1)

dat <- list(
  T = d$total_tools, 
  P = d$P, 
  cid = d$contact_id
)

# intercept only 
m11.9 <- ulam(alist(
  T ~ dpois(lambda), 
  log(lambda) <- a, 
  a ~ dnorm(3, 0.5)
), data = dat, chains = 4, log_lik = T)

# interaction model 
m11.10 <- ulam(alist(
  T ~ dpois(lambda),
  log(lambda) <- a[cid] + b[cid]*P,
  a[cid] ~ dnorm(3, 0.5),
  b[cid] ~ dnorm(0, 0.2)
), data = dat, chains = 4, log_lik = T)

compare(m11.9, m11.10, func=PSIS)

k <- PSIS(m11.10, pointwise = T)$k

ns <- 100 
P_seq <- seq(from = -1.4, to = 3, length.out=ns)
# predictions for low contact (cid = 1)
lambda <- link(m11.10, data = data.frame(P=P_seq, cid=1))
lmu <- apply(lambda, 2, mean)
lci <- apply(lambda, 2, PI)
lines(P_seq, lmu, lty=2, lwd = 1.5)
shade(lci, P_seq, xpd = T)

# predictions for high contact (cid = 2)
lambda <- link(m11.10, data = data.frame(P=P_seq, cid = 2))
lmu <- apply(lambda, 2, mean)
lci <- apply(lambda, 2, PI)
lines(P_seq, lmu, lty=1, lwd=1.5)
shade(lci, P_seq, xpd=T)


# Negative Binomial -------------------------------------------------------

# daily counts
num_days <- 30
y <- rpois(num_days, 1.5)

# weekly counts
num_weeks <- 4
y_new <- rpois(num_weeks, 0.5*7) # multiply average by 7 since there are 7 days in a week

y_all <- c(y, y_new)
exposure <- c(rep(1,30), rep(7, 4))
monastery <- c(rep(0,30), rep(1,4))
d <- data.frame(y=y_all, days=exposure, monastery = monastery)

# compute offset
d$log_days <- log(d$days)

# model 
m11.12 <- quap(alist(
  y ~ dpois(lambda), 
  log(lambda) <- log_days + a + b*monastery,
  a ~ dnorm(0, 1), 
  b ~ dnorm(0, 1)
), data = d)

# everything is on daily scale now - don't need offset 
post <- extract.samples(m11.12)
lambda_old <- exp(post$a)
lambda_new <- exp(post$a + post$b)
precis(data.frame(lambda_old, lambda_new))


# Multinomial/Categorical Models  -----------------------------------------

## Predictors Matched to Outcomes
# simulate career choices among 500 people 
N <- 500
income <- c(1,2,5)
score <- 0.5*income # scores for each career based on income
# convert scores to probabilities
p <- softmax(score[1], score[2], score[3])

# simulate choice 
career <- rep(NA, N)
# sample chosen career for each individual 
set.seed(34302)
for(i in 1:N) careeer[i] <- sample(1:3, size = 1, prob = p)

code_m11.13 <- "
data{ 
  int N; // number of individuals 
  int K; // number of possible careers 
  int career[N]; //outcome 
  vector[K] career_income;
}

parameters{
  vector[K-1] a; // intercepts
  real<lower=0> b; //association of income with choice
}

model{
  vector[K] p;
  vector[K] s;
  a ~ normal(0, 1);
  b ~ normal(0, 0.5);
  s[1] = a[1] + b*career_income[1]; 
  s[2] = a[2] + b*career_income[2];
  s[3] = 0; // pivot
  p = softmax(s); 
  career ~ categorical(p);
}
"
dat_list <- list(N=N, K=3, career=career, career_income=income)
m11.13 <- stan(model_code = code_m11.13, data = dat_list, chains = 4)
precis(m11.13, 2)

# conduct counterfactual sim - what happens if we increase income for salary 2?
post <- extract.samples(m11.13)
# logit scores
s1 <- with(post, a[,1] + b*income[1])
s2_orig <- with(post, a[,2] + b*income[2])
s2_new <- with(post, a[,2] + b*income[2]*2)

# compute probabilities
p_orig <- sapply(1:length(post$b), function(i)
  softmax(c(s1[i],s2_orig[i],0)))
p_new <- sapply(1:length(post$b), function(i)
  softmax(c(s1[i],s2_new[i],0)))

# summarize 
p_diff <- p_new[,2] - p_orig[,2]
precis(p_diff)

## Predictors Matched to Observations

# simulate family incomes among 500 people 
N <- 500
family_income <- runif(N)
b <- c(-2, 0, 2) # unique coefficient for each type of event
# simulate choice 
career <- rep(NA, N)
# sample chosen career for each individual 
for(i in 1:N){ 
  score <- 0.5*(1:3) + b*family_income[i]
  p <- softmax(score[1], score[2], score[3])
  careeer[i] <- sample(1:3, size = 1, prob = p)}

code_m11.14 <- "
data{ 
  int N; // number of individuals 
  int K; // number of possible careers 
  int career[N]; //outcome 
  real family_income[N];
}

parameters{
  vector[K-1] a; // intercepts
  vector[K-1] b; // coefficients of family income
}

model{
  vector[K] p;
  vector[K] s;
  a ~ normal(0, 1.5);
  b ~ normal(0, 1);
  for(i in 1:N){
    for(j in 1:(K-1)) s[j] = a[j] + b[j]*family_income[i];
    s[K] = 0; // the pivot
    p = softmax(s);
    career[i] ~ categorical(p);
  }
}
"
dat_list <- list(N=N, K=3, career=career, family_income=family_income)
m11.13 <- stan(model_code = code_m11.14, data = dat_list, chains = 4)
precis(m11.14, 2)


# Multinomial as Poisson --------------------------------------------------

data <- UCBadmit
d <- UCBadmit

# binomial model of admission probability 
m_binom <- quap(alist(
  admit ~ dbinom(applications, p),
  logit(p) <- a,
  a ~ dnorm(0, 1.5)
), data = d)

# Poisson model 
dat <- list(admit = d$admit, rej = d$reject)
m_pois <- ulam(
  alist(
    admit ~ dpois(lambda1),
    rej ~ dpois(lambda2),
    log(lambda1) <- a1,
    log(lambda2) <- a2,
    c(a1,a2) ~ dnorm(0, 1.5)
  ), data = dat, chains = 3, cores = 3
)

inv_logit(coef(m_binom))
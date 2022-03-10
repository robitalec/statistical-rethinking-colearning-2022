data {
  int<lower=0> N;
  
  vector[N] age;
  vector[N] happiness;
}

parameters {
  real<lower=0> sigma;
  real beta_age;
  real alpha;
}

model {
  sigma ~ exponential(1);
  beta_age ~ normal(0, 2);
  alpha ~ normal(0, 1);
  
  vector[N] mu = alpha + beta_age * age;
  happiness ~ normal(mu, sigma);
}


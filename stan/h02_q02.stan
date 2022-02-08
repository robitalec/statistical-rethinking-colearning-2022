data {
  int<lower=0> N;
  vector[N] weight;
  vector[N] age;
}

parameters {
  real<lower=0> sigma;
  real alpha;
  real<lower=0> beta_age;
}

model {
  alpha ~ normal(80, 15);
  beta_age ~ lognormal(0, 1);
  sigma ~ exponential(1);
  
  vector[N] mu;
  mu = alpha + beta_age * age;

  weight ~ normal(mu, sigma);

}


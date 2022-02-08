data {
  int<lower=0> N;
  vector[N] height;
  vector[N] weight;
}

parameters {
  real<lower=0> sigma;
  real alpha;
  real<lower=0> beta_height;
}

model {
  alpha ~ normal(60, 15);
  beta_height ~ lognormal(0, 1);
  sigma ~ exponential(1);
  
  vector[N] mu;
  mu = alpha + beta_height * height;

  weight ~ normal(mu, sigma);

}


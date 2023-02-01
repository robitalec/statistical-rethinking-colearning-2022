data {
  int<lower=0> N;
  vector[N] scale_weight;
  vector[N] scale_food;
}

parameters {
  real<lower=0> sigma;
  real alpha;
  real beta_food;
}

model {
  alpha ~ normal(0, 0.2);
  beta_food ~ normal(0, 0.5);
  sigma ~ exponential(1);

  vector [N] mu = alpha + beta_food * scale_food;

  scale_weight ~ normal(mu, sigma);
}
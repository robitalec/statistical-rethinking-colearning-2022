data {
  int<lower=0> N;
  vector[N] scale_area;
  vector[N] scale_food;
}

parameters {
  real<lower=0> sigma;
  real alpha;
  real<lower=0> beta_area;
}

model {
  vector [N] mu = alpha + beta_area * scale_area;
    
  alpha ~ normal(0, 0.2);
  beta_area ~ normal(0, 0.5);
  sigma ~ exponential(1);
  scale_food ~ normal(mu, sigma);
}
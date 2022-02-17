data {
  int<lower=0> N;
  vector[N] scale_weight;
  vector[N] scale_food;
}

parameters {
  real<lower=0> sigma;
  real alpha;
  real<lower=0> beta_food;
}

model {
  vector [N] mu = alpha + beta_food * scale_food;
    
  alpha ~ normal(0, 0.2);
  beta_food ~ normal(0, 0.5);
  sigma ~ exponential(1);
  
  scale_weight ~ normal(mu, sigma);
}
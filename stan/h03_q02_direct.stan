data {
  int<lower=0> N;
  vector[N] scale_weight;
  vector[N] scale_food;
  vector[N] scale_groupsize;
}

parameters {
  real<lower=0> sigma;
  real alpha;
  real<lower=0> beta_food;
  real<lower=0> beta_groupsize;
}

model {
  vector [N] mu = alpha + beta_food * scale_food + beta_groupsize * scale_groupsize;
    
  alpha ~ normal(0, 0.2);
  beta_food ~ normal(0, 0.5);
  beta_groupsize ~ normal(0, 0.5);
  sigma ~ exponential(1);
  
  scale_weight ~ normal(mu, sigma);
}
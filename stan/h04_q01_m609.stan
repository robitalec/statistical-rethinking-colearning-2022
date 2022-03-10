data {
  int<lower=0> N;
  int<lower=0> N_index_married;
  
  vector[N] age;
  vector[N] happiness;
  vector[N] index_married;
}

parameters {
  real<lower=0> sigma;
  real beta_age;
  
  vector[N_index_married] alpha;
}

model {
  sigma ~ exponential(1);
  beta_age ~ normal(0, 2);
  alpha ~ normal(0, 1)
  
  vector[N] mu = alpha[index_married] + beta_age * age;
  happiness ~ normal(mu, sigma);
}


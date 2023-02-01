// From h04_q01_m609 and h04_q01_m610
data {
  int<lower=0> N;
  int<lower=0> N_index_married;
  
  vector[N] age;
  vector[N] happiness;
  
  int index_married [N];
}

parameters {
  real<lower=0> sigma;
  real beta_age;
  
  vector[N_index_married] alpha;
  
  real<lower=0> sigma_wo;
  real alpha_wo;
  real beta_age_wo;
}

model {
  // Model with varying intercepts
  sigma ~ exponential(1);
  beta_age ~ normal(0, 2);
  alpha ~ normal(0, 1);
  
  vector[N] mu = alpha[index_married] + beta_age * age;
  happiness ~ normal(mu, sigma);
  
  // Model without varying intercepts
  sigma_wo ~ exponential(1);
  beta_age_wo ~ normal(0, 2);
  alpha_wo ~ normal(0, 1);
  
  vector[N] mu_wo = alpha_wo +  beta_age_wo * age;
  happiness ~ normal(mu_wo, sigma_wo);
}


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
}

transformed parameters {
  vector[N] mu = alpha[index_married] + beta_age * age;
}

model {
  sigma ~ exponential(1);
  beta_age ~ normal(0, 2);
  alpha ~ normal(0, 1);
  
  happiness ~ normal(mu, sigma);
}

generated quantities {
  // https://mc-stan.org/docs/2_29/functions-reference/normal-distribution.html
  vector[N] log_lik;
  for (n in 1:N) {
    log_lik[n] = normal_lpdf(happiness[n] | mu[n], sigma);
  }
}
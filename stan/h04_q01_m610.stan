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

transformed parameters {
  vector[N] mu = alpha + beta_age * age;
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

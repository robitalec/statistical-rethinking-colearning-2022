data {
  int<lower=0> N;
  
  vector[N] scale_doy;
  vector[N] scale_temp;
}

parameters {
  real<lower=0> sigma;
  real alpha;
  real beta_temp;
}

transformed parameters {
  vector[N] mu = alpha + beta_temp * scale_temp;
}

model {
  sigma ~ exponential(1);
  alpha ~ normal(0, 10);
  beta_temp ~ normal(0, 10);
  
  scale_doy ~ normal(mu, sigma);
}

generated quantities {
  // https://mc-stan.org/docs/2_29/functions-reference/normal-distribution.html
  vector[N] log_lik;
  for (n in 1:N) {
    log_lik[n] = normal_lpdf(scale_doy[n] | mu, sigma);
  }
}
data {
  int<lower=0> N;
  
  vector[N] scale_doy;
  vector[N] scale_temp;
}

parameters {
  real<lower=0> sigma;
  real alpha;
}

transformed parameters {
  real mu = alpha;
}

model {
  sigma ~ exponential(1);
  alpha ~ normal(0, 0.2);
  
  scale_doy ~ normal(mu, sigma);
}

generated quantities {
  // https://mc-stan.org/docs/2_29/functions-reference/normal-distribution.html
  vector[N] log_lik;
  for (n in 1:N) {
    log_lik[n] = normal_lpdf(scale_doy[n] | mu, sigma);
  }
}
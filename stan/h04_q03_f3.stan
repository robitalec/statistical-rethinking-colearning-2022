data {
  int<lower=0> N;
  
  vector[N] scale_doy;
  vector[N] scale_temp;
}

parameters {
  real<lower=0> sigma;
  real alpha;
  real beta_temp1;
  real beta_temp2;
}

transformed parameters {
  vector[N] mu;
  for (i in 1:N) {
    mu[i] = alpha + beta_temp1 * scale_temp[i] + beta_temp2 * scale_temp[i] ^ 2;
  }
  
}

model {
  sigma ~ exponential(1);
  alpha ~ normal(0, 10);
  beta_temp1 ~ normal(0, 10);
  beta_temp2 ~ normal(0, 10);
  
  scale_doy ~ normal(mu, sigma);
}

generated quantities {
  // https://mc-stan.org/docs/2_29/functions-reference/normal-distribution.html
  vector[N] log_lik;
  for (n in 1:N) {
    log_lik[n] = normal_lpdf(scale_doy[n] | mu, sigma);
  }
}
data {
  int<lower=0> N;
  vector[N] scale_weight;
  vector[N] scale_area;
  vector[N] scale_groupsize;
}

parameters {
  real<lower=0> sigma;
  real alpha;
  real beta_area;
  real beta_groupsize;
}

transformed parameters {
  vector [N] mu = alpha + beta_area * scale_area + beta_groupsize * scale_groupsize;
}

model {
  alpha ~ normal(0, 0.2);
  beta_area ~ normal(0, 0.5);
  beta_groupsize ~ normal(0, 0.5);
  sigma ~ exponential(1);

  scale_weight ~ normal(mu, sigma);
}

generated quantities {
  // https://mc-stan.org/docs/2_29/functions-reference/normal-distribution.html
  vector[N] log_lik;
  for (n in 1:N) {
    log_lik[n] = normal_lpdf(scale_weight[n] | mu[n], sigma);
  }
}
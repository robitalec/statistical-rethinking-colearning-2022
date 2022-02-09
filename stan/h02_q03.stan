data {
  int<lower=0> N;
  int<lower=0> N_sex;
  int sex[N];
  vector[N] weight;
  vector[N] age;
  
}

parameters {
  real<lower=0> sigma;
  vector[N_sex] beta_age;
  vector[N_sex] alpha;
}

model {
  alpha ~ normal(10, 5);
  beta_age ~ lognormal(0, 1);
  sigma ~ exponential(1);

  vector[N] mu;  
  for (i in 1:N) {
    mu[i] = alpha[sex[u]] + beta_age[sex[i]] * age[i];
  }

  weight ~ normal(mu, sigma);
}


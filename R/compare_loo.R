# LOO-PSIS: https://mc-stan.org/loo/reference/loo.html, https://mc-stan.org/loo/articles/loo2-with-rstan.html
compare_loo <- function(models) {
  ls_loo <- lapply(models, function(x) m$loo())
  loo_compare(ls_loo)
}
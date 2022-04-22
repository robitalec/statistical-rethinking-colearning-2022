sim_data <- function(abar, sigma){
  
  n <- 1e4
  
  abars <- rnorm(n, 0, abar)
  sigmas <- rexp(n, sigma)
  
  at <- rnorm(n, mean = abars, sd = sigmas)
  
  return(at)
  
}
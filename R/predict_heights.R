predict_heights <- function(draws, new_values, mean_height) {
  setDT(draws)
  
  new_values <- data.table(height = new_values)
  
  out <- new_values[, post[, rnorm(.N, alpha + beta_height * (.BY[[1]] - mean_height), sigma)],
                    by = height]
  setnames(out, 'V1', 'weight')
  return(out)
}
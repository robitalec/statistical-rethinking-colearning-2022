plot_rvars <- function(model, variable, regex = TRUE) {
  rv <- as_draws_rvars(model, variable = variable, regex = regex)[[1]]
  
  ggplot(data.frame(names = rownames(rv), rv)) + 
    stat_halfeye(aes(xdist = Intercept, y = names)) +
    theme_minimal()
}

# plot_rvars(mod_q02, 'r_tank')
# Error in data.frame(names = rownames(rv), rv) : 
#   arguments imply differing number of rows: 0, 48
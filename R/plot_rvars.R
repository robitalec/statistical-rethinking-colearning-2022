plot_rvars <- function(model, variable, regex = TRUE, nested = FALSE) {
  rvars <- as_draws_rvars(model, variable = variable, regex = regex)
  
  if (nested) {
    rvars_first <- rvars[[1]]
    a <- data.frame(#rownames(rvars_first), 
                    seq.int(length(rvars_first)),
                    rvars_first)
    colnames(a) <- c('nm', 'rv')
  } else {
    a <- data.frame(nm = names(rvars), 
                    rv = do.call(rbind, rvars))
  }
  ggplot(a) + 
    stat_halfeye(aes(xdist = rv, y = nm)) +
    theme_minimal()
}
# https://wlandau.github.io/targetopia/contributing.html
tar_brms <- function(name, formula, priors, data, sample_priors, chains = 4,
                     iter = 2000, cores = 1) {
  
  name_deparse <- deparse(substitute(name))
  data_deparse <- deparse(substitute(data))
  print(data_deparse)
  
  name_formula <- paste(name_deparse, 'formula', sep = '_')
  name_priors <- paste(name_deparse, 'priors', sep = '_')
  name_sample_priors <- paste(name_deparse, 'sample_priors', sep = '_')
  
  sym_formula <- as.symbol(name_formula)
  
  command_formula <- substitute(brmsformula(formula), 
                                env = list(formula = sym_formula))
  # command_priors <- substitute(priors, env = list(priors = as.symbol(name_priors)))
  # command_sample_priors <- substitute(
  #   brm(
  #     formula = formula,
  #     data = data,
  #     prior = priors,
  #     sample_prior = 'only'
  #   ),
  #   env = list(
  #     formula = as.symbol(name_formula),
  #     priors = as.symbol(name_priors),
  #     data = data
  #   )
  # )
  
  c(
    tar_target_raw(
      name_formula,
      command_formula
    ),
    tar_target_raw(
      name_priors,
      command_priors
    ),
    tar_target_raw(
      name_sample_priors,
      command_sample_priors
    ),
    tar_target_raw(
      name_sample_priors,
      command_sample_priors
    )
    
)}
#   # Fit the model, without priors
  # m <- brm(
  #   formula = f,
  #   data = DT,
  #   prior = priors
  # )
#   
#   # Note: "Rows containing NAs were excluded from the model."
#   
#   
#   
#   # Draws -------------------------------------------------------------------
#   plot(m)
#   summary(m)
#   conditional_effects(m)
#   
#   
#   
#   # LOO ---------------------------------------------------------------------
#   loo(m)
#   
#   
#   
#   
#   
#   # priors
#   # sample priors only
#   # make stan code
#   
#   # brms
#   # dont samle priors
#   
#   # draws
#   # summary
#   
# }
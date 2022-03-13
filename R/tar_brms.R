# https://wlandau.github.io/targetopia/contributing.html
tar_brms <- function(name, formula, prior, data, sample_priors) {
  
  # Handle if data, or if data = target??
  
  name_deparse <- deparse(substitute(name))
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
    )#,
    # tar_target_raw(
    #   name_priors,
    #   command_priors
    # )#,
    # tar_target_raw(
    #   name_sample_priors,
    #   command_sample_priors
    # )
    )#,
  #   tar_target_raw(
  #     priors_name,
  #     q(
  #       priors
  #     )
  #   ),
  #   if (sample_priors) {
  #     tar_target_raw(
  #       sample_priors_name,
  #         q(
  #           brm(formula = ,
  #               data = DT,
  #               prior = priors,
  #               sample_prior = 'only'
  #         )
  #     ),
  #   }
  #   tar_target_raw(
  #     
  #   )
  # 
  # )
}
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
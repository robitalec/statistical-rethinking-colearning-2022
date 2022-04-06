binom_total <- function(data) {
  
  data_list <- list(awards = data$awards, 
                    applications = data$applications, 
                    gender = ifelse(d$applicant.gender=="male"), 1, 2)
  
  brm(awards | trials(applications) ~ 0 + gender, data = data_list  ,
          family = binomial,
          prior = prior(normal(0, 1.5), class = b),
          iter = 4000, warmup = 2000, chains = 4, cores = 4, seed = 1234,
          file = here("fits", "hw5", "w5h1"))
  
}
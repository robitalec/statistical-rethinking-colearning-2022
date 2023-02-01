data_marriage <- function(only_adults = TRUE) {
  DT <- data.table(sim_happiness())
  
  DT[, index_married := .GRP, married]
  
  if (only_adults) {
    return(DT[age > 17][, age := (age - 18) / (65 - 18)])
  } else {
    return(DT)
  }
}

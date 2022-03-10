data_marriage <- function() {
  DT <- data.table(sim_happiness())
  
  DT[, index_married := .GRP, married]
  
  return(DT)
}

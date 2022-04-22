data_grants <- function() {
  data("NWOGrants")
  
  DT <- data.table(NWOGrants)
  
  DT[, index_gender := .GRP, gender]
  DT[, index_discipline := .GRP, discipline]
  
  DT[, gender := factor(gender)]
  DT[, discipline := factor(discipline)]

  return(DT)
}

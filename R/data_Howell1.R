data_Howell1 <- function() {
  data(Howell1)
  DT <- data.table(Howell1)
  DT[, sex := .GRP, by = male]
  
  return(DT[, .(height, weight, age, sex)])
}
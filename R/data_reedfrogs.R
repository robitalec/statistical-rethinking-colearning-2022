data_reedfrogs <- function() {
  data("reedfrogs")
  
  DT <- data.table(reedfrogs)
  
  DT[, tank := .I]
  
  DT[, index_pred := .GRP, pred]
  DT[, index_size := .GRP, size]
  
  DT[, pred := factor(pred)]
  DT[, size := factor(size)]
  DT[, tank := factor(tank)]
  
  DT[, scale_density := scale(density)]
  
  return(DT)
}

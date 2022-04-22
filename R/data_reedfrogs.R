data_reedfrogs <- function() {
  data("reedfrogs")
  
  DT <- data.table(reedfrogs)
  
  DT[, index_pred := .GRP, pred]
  DT[, index_size := .GRP, size]
  
  DT[, pred := factor(pred)]
  DT[, size := factor(size)]
  
  return(DT)
}

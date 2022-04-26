data_bangladesh <- function(scale = FALSE) {
  data(bangladesh)
  DT <- data.table(bangladesh)
  
  DT[, use_contraception := factor(use.contraception)]
  DT[, district := factor(district)]
  DT[, woman := factor(woman)]
  DT[, urban := factor(urban)]
  
  return(DT)
}

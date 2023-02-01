data_bangladesh <- function(scale = FALSE) {
  data(bangladesh)
  DT <- data.table(bangladesh)
  
  DT[, district := factor(district)]
  DT[, woman := factor(woman)]
  DT[, urban := factor(urban)]
  
  setnames(DT, 
           c('use.contraception', 'living.children', 'age.centered'),
           c('use_contraception', 'living_children', 'age_centered'))
  
  return(DT)
}

data_foxes <- function(scale = FALSE) {
  data(foxes)
  DT <- data.table(foxes)

  if (scale) {
    message('Scaling numeric variables: avgfood, groupsize, area, weight')
    DT[, scale_avgfood := as.numeric(scale(avgfood))]
    DT[, scale_groupsize := as.numeric(scale(groupsize))]
    DT[, scale_area := as.numeric(scale(area))]
    DT[, scale_weight := as.numeric(scale(weight))]
  }
    
  return(DT[])
}

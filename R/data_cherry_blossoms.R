data_cherry_blossoms <- function(scaled = TRUE, drop_na = FALSE) {
  data(cherry_blossoms)
  DT <- data.table(cherry_blossoms)
  
  if (scaled) {
    DT[, scale_year := scale(year)]
    DT[, scale_doy := scale(doy)]
    DT[, scale_temp := scale(temp)]
    DT[, scale_temp_upper := scale(temp_upper)]
    DT[, scale_temp_lower := scale(temp_lower)]
  }
  
  return(DT)
}
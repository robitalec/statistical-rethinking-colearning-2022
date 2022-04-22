data_frog <- function(){
  
  data("reedfrogs", package = "rethinking")
  
  d <- reedfrogs
  
  d <- as.data.table(d)
  
  return(d)
  
}

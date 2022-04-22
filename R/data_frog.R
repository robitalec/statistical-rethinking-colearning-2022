data_frog <- function(){
  
  data("reedfrogs", package = "rethinking")
  
  d <- reedfrogs
  
  d <- as.data.table(d)
  
  d$tank <- 1:nrow(d) # create tank variable 
  
  # create indexed variables of predation and size 
  d$predind <- ifelse(d$pred == "no", 1L, 2L)
  d$sizind <- ifelse(d$size == "small", 1L, 2L)
  
  return(d)
  
}

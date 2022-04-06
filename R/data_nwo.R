data_nwo <- function(){
  
  data("NWOGrants")
  
  d <- NWOGrants
  
  d <- as.data.table(d)
  
  return(d)
  
}
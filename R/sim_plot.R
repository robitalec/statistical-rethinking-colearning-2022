sim_plot <- function(data){
  
  data <- inv_logit_scaled(data)
  
  data <- as.data.table(data)
  
  ggplot(data, aes(x = data)) + 
    geom_density()
  
}
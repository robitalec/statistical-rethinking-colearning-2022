# Packages ------------------------------------
library(rethinking)

# King Markov ---------------------------------
num_weeks <- 1e5
positions <- rep(0, num_weeks)
current <- 10
for(i in 1:num_weeks){
  # record current position 
  positions[i] <- current 
  # flip coin 
  proposal <- current + sample(c(-1,1), size =1)
  # loop the archipelago
  if (proposal < 1) proposal <- 10
  if (proposal > 10) proposal <- 1
  # move
  prob_move <- proposal/current 
  current <- ifelse(runif(1) < prob_move, proposal, current)
}
plot(table(positions))

# Hamiltonian Monte Carlo ---------------------
rm(list=ls())
data(rugged)
d <- rugged

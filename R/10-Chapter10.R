
# Packages ----------------------------------------------------------------

library(rethinking)


# Data --------------------------------------------------------------------

p <- list()
p$A <- c(0,0,10,0,0)
p$B <- c(0,1,8,1,0)
p$C <- c(0,2,6,2,0)
p$D <- c(1,2,4,2,1)
p$E <- c(2,2,2,2,2)


# Maximum Entropy ---------------------------------------------------------

# create probability distribution 
p_norm <- lapply(p, function(q) q/sum(q))

# calculate information entropy
H <- sapply(p_norm, function(q) - sum(ifelse(q==0, 0, q*log(q))))

# number of ways each combination can happen 
ways <- c(1, 90, 1260, 37800, 113400)

# log ways per pebble for each distribution 
logwayspp <- log(ways)/10


# Binomial Distributions --------------------------------------------------
# candidate distributions
p <- list()
p[[1]] <- c(1/4, 1/4, 1/4, 1/4)
p[[2]] <- c(2/6, 1/6, 1/6, 2/6)
p[[3]] <- c(1/6, 2/6, 2/6, 1/6)
p[[4]] <- c(1/8, 4/8, 2/8, 1/8)
# expected value of each
sapply(p, function(p) sum(p)*c(0,1,1,2))
# entropy of each 
sapply(p, function(p) -sum(p*log(p)))

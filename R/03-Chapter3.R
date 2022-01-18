#### Vampire Problem ####
# probability that test correctly detects vampirism - Pr(Positive|Vampire) 
Pr_Positive_Vampire <- 0.95
# probability of false positive (test confirms vampirism in mortal) - Pr(Positive|Mortal)
Pr_Positive_Mortal <- 0.01
# probability of vampires in the general population - Pr(Vampire)
Pr_Vampire <- 0.001
# average probability of a positive test
Pr_Positive <- Pr_Positive_Vampire * Pr_Vampire + Pr_Positive_Mortal * ( 1 - Pr_Vampire )
# probability that someone is a vampire given a positive test (Pr(Vampire|Positive))
Pr_Vampire_Positive <- Pr_Positive_Vampire*Pr_Vampire / Pr_Positive

#### Sampling Posterior #### 
p_grid <- seq( from=0 , to=1 , length.out=1000 )
prob_p <- rep( 1 , 1000 )
prob_data <- dbinom( 6 , size=9 , prob=p_grid )
posterior <- prob_data * prob_p
posterior <- posterior / sum(posterior)
# sample your posterior distribution 10,000 times with replacement 
samples <- sample(p_grid, prob=posterior , size=1e4 , replace=TRUE )
# this plot shows distribution of samples (birds eye view of posterior)
# extremely dense near 0.6 with few samples near 0.2
plot(samples)
# can plot the density estimate of your samples as well 
library(rethinking)
dens(samples)

#### Summarizing #### 
# Grid approximation method
# add up posterior probability where p < 0.5 to see probability that proportion of water is < 50% 
sum(posterior[p_grid < 0.5])
# Sampling method 
# sum probability where p < 0.5 AND divide by number of samples
sum(samples < 0.5) / 1e4
# can also test the probability within intervals 
sum( samples > 0.5 & samples < 0.75 ) / 1e4
# calculating the lower 80% credible interval
quantile(samples , 0.8 )
# can calculate the middle 80% interval by saying the 80th quantile lays between the 10th and 90th
quantile( samples, c( 0.1 , 0.9 ) )

# Misleading PI 
p_grid <- seq( from=0 , to=1 , length.out=1000 )
prior <- rep(1,1000)
likelihood <- dbinom( 3 , size=3 , prob=p_grid )
posterior <- likelihood * prior
posterior <- posterior / sum(posterior)
samples <- sample( p_grid , size=1e4 , replace=TRUE , prob=posterior )
PI( samples , prob=0.5 )
# sampling to 50% PI excludes the most likely values of the posterior distribution in this model
HPDI(samples, prob = 0.5)
# HDPI more accurately represents the data

# Calculating the MAP 
# grid approximation
p_grid[ which.max(posterior) ]
# sampling 
chainmode( samples , adj=0.01 )
# can also calculate mean and median 
mean(samples)
median(samples)

# Loss Estimation/Loss Functions 
# calculate expected loss for p = 0.5
sum( posterior*abs( 0.5 - p_grid ) )
# calculate for every possible value using sapply
loss <- sapply( p_grid , function(d) sum( posterior*abs( d - p_grid ) ) )
p_grid[ which.min(loss) ] # minimum loss is same value as median 

#### Simulating Prediction ####
# compute the probability of each value 0, 1, 2 given a probability of 0.7 and sample size of 2 
dbinom(0:2 , size=2 , prob=0.7 )
# simulate an observation by sampling the distribution
rbinom( 1 , size=2 , prob=0.7 )
rbinom( 10 , size=2 , prob=0.7 )
# generate 10,000 samples 
dummy_w <- rbinom( 1e5 , size=2 , prob=0.7 )
table(dummy_w)/1e5 # confirm probability distributions of each value match initial calc on l72
# improve sample size from 2 to 9
dummy_w <- rbinom( 1e5 , size=9 , prob=0.7 )
simplehist( dummy_w , xlab= "dummy water count" )

#### Practice Questions ####
# practice data 
p_grid <- seq( from=0 , to=1 , length.out=1000 )
prior <- rep( 1 , 1000 )
likelihood <- dbinom( 6 , size=9 , prob=p_grid )
posterior <- likelihood * prior
posterior <- posterior / sum(posterior)
set.seed(100)
samples <- sample( p_grid , prob=posterior , size=1e4 , replace=TRUE )

# 3E1.  How much posterior probability lies below p = 0.2?
sum(samples < 0.2) / 1e4
# 3E2.  How much posterior probability lies above p = 0.8?
sum(samples > 0.8) / 1e4
# 3E3.  How much posterior probability lies between p = 0.2 and p = 0.8?
sum( samples > 0.2 & samples < 0.8 ) / 1e4
# 3E4.  20% of the posterior probability lies below which value of p?
quantile(samples, 0.2)
# 3E5.  20% of the posterior probability lies above which value of p?
quantile(samples, 0.8)
# 3E6.  Which values of p contain the narrowest interval equal to 66% of the posterior probability?
HPDI(samples, prob = 0.66)
# 3E7.  Which values of p contain 66% of the posterior probability, assuming equal posterior probability both below and above the interval?
PI(samples, prob = 0.66)

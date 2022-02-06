library(rethinking)
data(Howell1)
d <- Howell1
df <- d[d$age <13,]

#############################
#### FULLY LUXE BAYESIAN ####
#############################



# sample sizes

# plot priors 
N <- 100
# 100 lines
a <- rnorm( N , 5 , 1 )
b <- rlnorm( N , 0 , 1  )

plot( NULL , xlim=range(df$age) , ylim=c(-50,100) ,
xlab="Age (Yrs)" , ylab="weight (Kg)" )
abline( h=0 , lty=2 )
abline( h=50 , lty=1 , lwd=0.5 )
mtext( "b ~ dlnorm(0,1)" )
xbar <- mean(df$age)
for ( i in 1:N ) curve( a[i] + b[i]*(x - xbar) ,
    from=min(df$age) , to=max(df$age) , add=TRUE ,
    col=col.alpha("black",0.2) )


# plot data for weight vs height
plot(df$height,df$weight,main="age < 13 years old")



# The linear model 
# weight ~ Normal(mu,sigma) # the distribution we believe x to have 
# mu = alpha_W + beta_A*(age - age_bar) #since we only care about a linear relation between age and weight
# alpha_W ~ Normal(Mean weight, Standard Deviation)
# Beta_A ~ LogNormal(mean age, standard deviation
# sigma_W ~ 
age_bar <- mean(df$age)
model <- quap( # quadratic approximation
                alist( # linear model written as a list

                      # how age  effects weight
                      weight ~ dnorm(mu_W,sigma_W),
                      mu_W <- alpha_W + beta_A*(age - age_bar) ,
                      alpha_W ~ dnorm(3.5, 1.5),
                      beta_A ~ dlnorm(0,1),
                      sigma_W ~ dexp(1)
                      ), data=df)

# summarize the model
precis(model)

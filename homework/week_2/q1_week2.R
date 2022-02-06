library(rethinking)
data(Howell1)
d <- Howell1
df <- d[d$age >= 18,]

# sample size
x <- 1e4

# plot priors 
curve(dnorm(x,178,20) ,from=100,to=250)
curve(dunif(x,0,50) ,from=-10,to=60)



# draw from priors to plot hight 
mu <- rnorm(x,178,20)
sigma <- runif(x,0,50)
prior_h <- rnorm(x,mu,sigma)
dens(prior_h)


# plot data for weight vs height
plot(df$height,df$weight,main="Weight vs Height (age>=18)")



# The linear model
# x ~ Normal(mu_i,sigma) # the distribution we believe x to have 
# u_i = alpha + beta*(x_i-x_bar) # the linear model, i is the i'th sample in the data and x_bar is the mean
# aplha ~ Normal(mean_we_are_assuming,std_we_are_assuming ) # prior for alpha 
# beta ~ Normal(mean_we_are_assuming,std_we_are_assuming ) # this is a bad assumption
# beta ~ LogNormal(mean_we_are_assuming,std_we_are_assuming ) # this is better 
# sigma ~ Uniform(lower_bound_for_sigma, upper_bound_for_sigma )


height_bar <- mean(df$height)
model <- quap( # quadratic approximation
                alist( # linear model written as a list
                      weight ~ dnorm(mu,sigma),
                      mu <- a + b*(height - height_bar),
                      a ~ dnorm(45, 10),
                      b ~ dlnorm(0,1),
                      sigma ~ dunif(0,50)
                      ), data=df)

# get 10000 (default) samples using the model 
posterior <- extract.samples(model) 
# get an average value for alpha in the linear model
alpha <- mean(posterior$a)
# get an average value for beta from the linear model
beta <- mean(posterior$b)

# get estimates for specific height
heights_of_interest <- c(140,160,175)

# conf_int = c()
lower = c()
upper = c()
averages = c()
# loop through all heights of interest 
for(hoi in heights_of_interest)
{
    interval <- PI(alpha + beta*(hoi-height_bar),prob=0.89)
    average <- mean(alpha + beta*(hoi-height_bar))
    print(sprintf("For a person of height of %i cm, expected weight is %.2f Kg with PI = (%.2f,%.2f) Kg", hoi,average ,interval[[1]],interval[[2]]) )

    # conf_int <- c(conf_int, as.tuples(interval[[1]],interval[[2]]) )
    lower <- c(lower,interval[[1]])
    upper <- c(upper,interval[[2]])
    averages <- c(averages, average )
}

# print(conf_int)
new_df <-data.frame( Individual = c(1,2,3), 
                    Height = heights_of_interest,
                    Expected.Weight = averages,
                    Lower.Interval = lower,
                    Upper.Interval = upper
                    )
write.csv(new_df,"Q1.csv",row.names=FALSE)




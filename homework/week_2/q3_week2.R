library(rethinking)
data(Howell1)
d <- Howell1
df <- d[d$age <13,]

set.seed(1)

# sample size

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
# mu = alpha_W[sex] + beta_A[sex]*(age) #since we only care about a linear relation between age and weight
# alpha_W[sex] ~ Normal(Mean weight, Standard Deviation)
# Beta_A[sex] ~ LogNormal(mean age, standard deviation
# sigma_W ~ exponential(1) 


df$male <- df$male + 1 # 1 == female 2 ==male
model <- quap( # quadratic approximation
                alist( # linear model written as a list

                      # how age  effects weight
                      weight ~ dnorm(mu_W,sigma_W),
                      mu_W <- alpha_W[male] + beta_A[male]*age ,
                      # mu_W <- alpha_W[Sex] + beta_A[Sex]*(Age - age_bar),
                      alpha_W[male] ~ dnorm(3.5, 1.5),
                      beta_A[male] ~ dlnorm(0,1),
                      sigma_W ~ dexp(1)
                      ), data=df)




age_seq <- 0:12
Fe = 6 # colour for females
Ma = 3 # colour for males 
print(model)
plot(df$age,df$weight,col=ifelse(df$male==1,Fe,Ma))

mu_F <- link(model,data=list(age=0:12,male=rep(1,13)) )
shade(apply(mu_F,2,PI,0.99), age_seq, col=col.alpha(Fe,0.5))
lines(age_seq, apply(mu_F,2,mean),lwd=3,col=Fe)

mu_M <- link(model,data=list(age=0:12,male=rep(2,13)) )
shade(apply(mu_M,2,PI,0.99), age_seq,col=col.alpha(Ma,0.5))
lines(age_seq,apply(mu_M,2,mean),lwd=3,col=Ma)

legend("top",legend=c("Female","Male"),col=c(Fe,Ma),cex=1 ,lty=1)  


# now plot contrast stuff 

muF <- sim(model,data=list(age=0:12,male=rep(1,13)) )
muM <- sim(model,data=list(age=0:12,male=rep(2,13)) )


mu_contrast = muM - muF
plot(NULL,xlim=c(0,13), ylim=c(-15,15), xlab="Age",ylab="Weight difference (Males - Females)")

for (p in c(0.5,0.67,0.89,0.99))
{
    shade(apply(mu_contrast,2,PI,prob=p), age_seq)
    abline(h=0,lty=2,lwd=2)
}


## Homework Week 4

**Question 1:** Revisit the marriage, age, and happiness collider bias
example from Chapter 6. Run models m6.9 and m6.10 again (pages 178–179).
Compare these two models using both PSIS and WAIC. Which model is
expected to make better predictions, according to these criteria? On the
basis of the causal model, how should you interpret the parameter
estimates from the model preferred by PSIS and WAIC?

``` r
d <- sim_happiness()
d2 <- d[d$age > 17, ]
d2$A <- (d2$age - 18) / (65 - 18) # rescale so age is one unit 
d2$mid <- d2$married + 1 # recode categorical variable 

m6.9 <- quap(
  alist(
    happiness ~ dnorm(mu, sigma),
    mu <- a[mid] + bA*A,
    a[mid] ~ dnorm(0,1),
    bA ~ dnorm(0,2),
    sigma ~ dexp(1)
  ), data = d2
)

m6.10 <- quap(
  alist(
    happiness ~ dnorm(mu, sigma),
    mu <- a + bA*A,
    a ~ dnorm(0,1),
    bA ~ dnorm(0,2),
    sigma ~ dexp(1)
  ), data = d2
)

compare(m6.9, m6.10, func=WAIC)
```

    ##           WAIC       SE    dWAIC      dSE    pWAIC       weight
    ## m6.9  2713.971 37.54465   0.0000       NA 3.738532 1.000000e+00
    ## m6.10 3101.906 27.74379 387.9347 35.40032 2.340445 5.768312e-85

``` r
compare(m6.9, m6.10, func=PSIS)
```

    ##           PSIS       SE    dPSIS      dSE    pPSIS       weight
    ## m6.9  2714.289 37.53161   0.0000       NA 3.878050 1.000000e+00
    ## m6.10 3101.901 27.69888 387.6116 35.34503 2.337216 6.779832e-85

# age is negatively associated with happiness because of collider bias

# remove marriage status from model and this collider bias disappears and there is no relationship

**Question 2:** Reconsider the urban fox analysis from last week’s
homework. On the basis of PSIS and WAIC scores, which combination of
variables best predicts body weight (W, weight)? How would you interpret
the estimates from the best scoring model?

**Question 3:** Build a predictive model of the relationship show on the
cover of the book, the relationship between the timing of cherry
blossoms and March temperature in the same year. The data are found in
data(cherry\_blossoms). Consider at least two functions to predict doy
with temp. Compare them with PSIS or WAIC. Suppose March temperatures
reach 9 degrees by the year 2050. What does your best model predict for
the predictive distribution of the day-in-year that the cherry trees
will blossom?

**Question 4:** The data in data(Dinosaurs) are body mass estimates at
different estimated ages for six different dinosaur species. See
?Dinosaurs for more details. Choose one or more of these species (at
least one, but as many as you like) and model its growth. To be precise:
Make a predictive model of body mass using age as a predictor. Consider
two or more model types for the function relating age to body mass and
score each using PSIS and WAIC. Which model do you think is best, on
predictive grounds? On scientific grounds? If your answers to these
questions differ, why? This is a challenging exercise, because the data
are so scarce. But it is also a realistic example, because people
publish Nature papers with even less data. So do your best, and I look
forward to seeing your growth curves.

**Coworking Group Question:** Take a question/model from your own work,
and draw the DAG. Try to think about unobserved variables in addition to
things you did measure. List the variables in your DAG and define them.
What are the units? What is a reasonable range of values (using
information from a different source than your own data)? Define or
justify the edges in your DAG. Just a sentence or two, but enough to
clarify why you/literature/science/logic think this relationship exists.

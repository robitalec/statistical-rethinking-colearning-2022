# Statistical Rethinking 2022 - Lecture 04

## Categories

Discrete, unordered types

Options: 

1. Indicator variables (0, 1, 1, 0, ...)
2. Index variables (1, 2, 3, 4, 5, ...)

Index variables are preferred and more easily extent to multilevel models. 

## Priors

Specifying priors for categorical variables: usually assign the same prior
for each type in the category since this is the most neutral approach. 

## Computing contrasts

We can't compare overlap in parameters  (eg. a precis output) directly, 
we need to compute the distribution of differences. 


Given the posterior, compute the difference in the posterior predicted variable
between groups and plot the histogram. 

Alternatively, you can simulate from the posterior distribution and plot the
contrast directly. 

## Full Luxury Bayesian

Include the full causal model in one statistical model

See other note where this is expanded on

## Curves

Types of linear models fit with curves: 

* polynomials
* splines and GAMs 

Splines and GAMs are generally preferred. 

### Polynomials 

Include a higher order polynomial term to add a curvature to the linear model. 
These models are geocentric and symmetrical, which generally doesn't match
scientific background or theory. They are also very error prone outside 
of the scope of the data. 

Note: It is always an improvement of fit to include another polynomial term. 

### Splines

Splines are built from functions that are locally smooth. These are not a 
mechanistic model. 

B splines / basis splines are linear regressions with synthetic variables. 

Ideally, use scientific information to build a mechanistic model instead. 
More about this later in the course. 



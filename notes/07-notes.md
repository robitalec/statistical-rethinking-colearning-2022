# Statistical Rethinking 2022 - Lecture 07

## Prediction

Parsing "prediction":

- What function describes the point? (fitting)
- What function explains the point? (causal inference)
- What would happen if we changed a point's variable X? (intervention, causal inference)
- What is the next observation from the same process? (prediction)

## Leave-one-out cross validation (LOO)

1. Drop one point
1. Fit line to remaining points
1. Predict the dropped point
1. Repeat with the next point
1. Score is the error on dropped points

In this example, think of each point as a posterior distribution. Bayesian cross
validation uses the entire posterior, not just point prediction.

Compared to the linear model, a first order polynomial has better in sample
score but worse out of sample score. For simple models without hierarchical 
structure, increasing the number of parameters (eg.
increasing the order polynomial) will increase in sample score but decrease
out of sample score. Regardless, this doesn't mean the model with N parameters
explains the process, just that it is best at prediction. Note: prediction
without intervention, because intervention requires an understanding of the
causal structure. 

"Fitting is easy but prediction is hard"

![](../graphics/notes/in-out-sample-polynomial.png)



## Regularization

Over-fitting results from flexibility. In the Bayesian context, flexibility
is determined in part by the priors (also parameters, their relationships, etc.).
Priors that don't contain much information will lead to a more flexible model. 

Skeptical or regularizing priors have tighter variance, reducing flexibility,
which can improve out of sample predictions. 
Regularization means to find regular features of processes. A good model
will only find the regular features and not also the irregular features. 

Picking priors: for causal inference, use science and think about possible 
outcome range, limits on physical or biological processes. Then go a bit wider. 
For pure prediction, tune using cross validation. 

Given N data points, LOO runs N models. This can be really costly. More efficient
alternatives include importance sampling (PSIS) and information criterion (WAIC). 

## Importance sampling

Points with low probability according to the model have a strong influence on
the posterior distribution. Importance sampling uses a single posterior 
distribution for N points to sample each posterior for N-1 points. How 
does the posterior change if one point at a time is removed? 

Leaving out points in the most probable regions does not greatly influence 
the posterior, but leaving out less probable points has a greater influence. 

Importance sampling estimates the posterior and it can have high variable and 
low stability. Smoothing, eg. by Pareto smooothed importance sampling (PSIS), 
helps improve stability and reduce the variance. It also returns useful 
diagnostics indicating highly influential points. It is a point wise
measurement of importance. 

## Information criteria

AIC = -2 * lppd + 2k

k: number of parameters
lppd: log pointwise predictive density

Basic AIC requires a normal posterior distribution, flat priors, etc. Fine
for simple linear regressions, but not broadly useful. Alternatively, use 
the Widely Applicable Information Criteria (WAIC). It is very similar
to PSIS but WAIC does not have automatic diagnostics. 

PSIS, WAIC and LOO are measures of overfitting, but they can't do anything
about it. Regularization manages overfitting in models. None of PSIS, WAIC, 
LOO or regularization address causal inference. 

## Model mis-selection

Do not use predictive criteria (WAIC, PSIS, LOO) to choose a causal estimate. 
Predictive criteria typically prefer confounds and colliders. 

Eg. plan growth


- T -> H1 <- H0
- T -> F -> H1 <- H0

Stratifying on fungus is the wrong adjustment set for identifying the total
causal effect of T on H1, this is stratifying on a post treatment variable. 

The biased model shows no treatment effect. Comparing the PSIS, the biased model
giving the wrong inference makes better predictions out of sample. 

## Outliers

Some points are more influential than others. "Outliers" are observations in the 
tails of the predictive distribution. Outliers (data) are not wrong, and shouldn't
be arbitrarily removed - the model that can't handle them is wrong. One solution
is to use a mixture model (robust regression). 

### Mixing Gaussians

Eg. divorce rate

Two states are outliers. The normal distribution expects a specific variance, 
but the unobserved heterogeneity leads to a mixture of Gaussian distributions. 
Combining Gaussian distributions with difference variances yields a Student-t
distribution. The Student-t distribution has thicker tails, expects more 
extreme points and is less vulnerable to making bad predictions. The extra 
variable required to define a Student-t distribution is hard to specify
because shape of tails is not easy to guess/predict. 

Result of using the Student-t distribution: stronger relationship from
age at marriage and overall narrower posterior

# Statistical Rethinking 2022 - Lecture 06

## Do calculus

`P(Y | do(X))` = 
The distribution of Y, stratified by X and U, averaged over the distribution of U

`do(X)` means to intervene on X. The distribution of Y conditional 


The causal effect of X on Y is not the coefficient relating X to Y, it is the distribution of Y when we change X, averaged over the distributions of the control variables (=marginal effect). 


### Back door criterion

The back door criterion is the rule to find the set of variables to stratify by to yield `P(Y | do(X))`

1. Identify all paths connecting treatment to the outcome, regardless of direction of arrows. 
2. Identify paths with arrows entering the treatment (back door). These are non casual paths, because causal paths exit the treatment (front door). 
3. Find adjustment sets that close back door paths. 

## Table 2 Fallacy

Not all coefficients represent causal effects. The statistical model designed to model the causal effect of X on Y will not also necessarily identify the causal effects of control variables. 

A table including all coefficients from a model as if they are all causal effects is wrong and misleading. Some variables are included as controls, eg. to close back doors into the treatment variable. 

Alternatively, present only the coefficients for causal variables, or provide an explicit interpretation of the coefficients as justified by the causal structure. 
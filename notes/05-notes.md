# Statistical Rethinking 2022 - Lecture 05

## Standardizing variables

Z score = (x - mean(x)) / std(x)

Standardizing variables helps computation, and makes it is easier to choose sensible priors. Priors for standardized variables should not have huge variation because it risks exaggerated or unreasonable slopes. 

## Four elemental confounds

### The fork

`X <- Y -> Y`

Z is a confound, a common cause of X and Y. X are Y only appear to be associated given their shared relationship with Z. As Z changes, both X and Y change though not necessarily in the same way. 

### The pipe

`X -> Z -> Y`

Z is a confound, a mediator between X and Y. X and Y are associated unless we condition on Z. Z is "contaminated" by X. 


### The collider

`X -> Z <- Y`

Z is a confound, a collider between X and Y. X and Y share no common causes and once Z is included X and Y appear to be associated. 

### The descendant

`X -> Z -> Y`
`Z -> A`

A is a descendant of Z. A tends to have the same effect as Z, so if Z is a collider, A will be a collider, etc. 



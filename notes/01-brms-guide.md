brms guide
================
Alec L. Robitaille
Winter 2022

-   [Overview](#overview)
-   [Formulas](#formulas)
    -   [response](#response)
        -   [Non-linear models](#non-linear-models)
        -   [Multivariate models](#multivariate-models)
    -   [aterms](#aterms)
        -   [Families: all](#families-all)
        -   [Families: gaussian, student,
            skew_normal](#families-gaussian-student-skew_normal)
        -   [Families: binomial and zero inflated
            binomial](#families-binomial-and-zero-inflated-binomial)
        -   [Families: ordinal](#families-ordinal)
        -   [Families: log-linear,
            e.g. poisson](#families-log-linear-eg-poisson)
        -   [Families: all except categorical and
            ordinal](#families-all-except-categorical-and-ordinal)
        -   [Families: all continuous
            families](#families-all-continuous-families)
        -   [Multivariate models](#multivariate-models-1)
        -   [Families: non-linear](#families-non-linear)
    -   [pterms](#pterms)
        -   [pterms: non-linear](#pterms-non-linear)
        -   [pterms: gaussian process](#pterms-gaussian-process)
        -   [pterms: monotonic](#pterms-monotonic)
        -   [pterms: measurement error](#pterms-measurement-error)
        -   [pterms: missing values](#pterms-missing-values)
        -   [pterms: category specific](#pterms-category-specific)
    -   [gterms and group level terms](#gterms-and-group-level-terms)
        -   [Modeling without
            correlations](#modeling-without-correlations)
        -   [Modeling with correlations](#modeling-with-correlations)
        -   [gterms: monotonic, measurement error, missing values,
            category
            specific](#gterms-monotonic-measurement-error-missing-values-category-specific)

## Overview

(Synthesis/organization/reorganization/etc of the `brms` manual and
associated resources)

## Formulas

`?brmsformula`

`response | aterms ~ pterms + (gterms | group)`

### response

`response | aterms ~ pterms + (gterms | group)`

Response variable

#### Non-linear models

<!-- TODO -->

#### Multivariate models

Multivariate models may be specified using mvbind notation or with help
of the
[mvbf](https://paul-buerkner.github.io/brms/reference/mvbrmsformula.html)
function. E.g. `mvbind(y1, y2) ~ x`. The effects of all terms specified
at the RHS of the formula are assumed to vary across response variables.
For instance, two parameters will be estimated for x, one for the effect
on y1 and another for the effect on y2. This is also true for
group-level effects. When writing, for instance,
`mvbind(y1, y2) ~ x + (1+x|g)`, group-level effects will be estimated
separately for each response. To model these effects as correlated
across responses, use the ID syntax. For the present example, this would
look as follows: `mvbind(y1, y2) ~ x + (1+x|2|g)`. Of course, you could
also use any value other than 2 as ID.

It is also possible to specify different formulas for different
responses. If, for instance, y1 should be predicted by x and y2 should
be predicted by z, we could write `mvbf(y1 ~ x, y2 ~ z)`. Alternatively,
multiple brmsformula objects can be added to specify a joint
multivariate model.

### aterms

`response | aterms ~ pterms + (gterms | group)`

Additional response information. One or multiple terms where each term
has the form `function(variable)`, and if multiple, separated by `+`.

Options include: se, weights, subset, cens, trunc, trials, cat, dec,
rate, vreal, or vint.

More information
[here](https://paul-buerkner.github.io/brms/reference/addition-terms.html).

#### Families: all

Weighted regression using weights,
e.g. `yi | weights(wei) ~ predictors`. Internally, this is implemented
by multiplying the log-posterior values of each observation by their
corresponding weights.

#### Families: gaussian, student, skew_normal

Standard error of observations, e.g. `yi | se(sei) ~ 1`. By default, the
standard errors replace the parameter sigma. To model sigma in addition
to the known standard errors, set argument sigma in function se to TRUE,
for instance, `yi | se(sei, sigma = TRUE) ~ 1`.

#### Families: binomial and zero inflated binomial

The number of trials underlying each observation should be specified
using the trials function. Do not use cbind like lme4, use e.g. 
`success | trials(n) ~ predictor`.

#### Families: ordinal

The number of thresholds, equal to the total number of response
categories - 1, can be defined using the function `thres.` E.g.,
`y | thres(6) ~ 1`. If the number of thresholds differs by groups in the
data, the gr argument can be used to define the grouping and the number
of thresholds can be in the form of an argument,
e.g. `y | thres(n_thresh, gr = grouping_var) ~ 1`. If not provided, the
number of thresholds is calculated from the data.

#### Families: log-linear, e.g. poisson

Rate may be used to specify the denominator of a response that is
expressed as a rate. The numerator is given by the response variable.
This is the preferred alternative to adding `offset(log(denominator))`
to the predictor terms. Eg. `yi | rate(denom) ~ 1`.

#### Families: all except categorical and ordinal

Left, right and interval censoring can be modeled using e.g. 
`y | cens(censored) ~ predictors`. Censored is the name of the variable
in the data that indicates the observation is either “left”, “none”,
“right” and “interval” censored. Either these words, or equivalently -1,
0, 1, 2. Interval censored data requires an additional y2 variable that
gives the upper bounds, where intervals assumed open on the left and
closed on the right (y, y2\].

Response distributions can be truncated using the `trunc` function. E.g.
if the response variable is truncated between 0 and 100, the
corresponding code is `yi | trunc(lb = 0, ub = 100) ~ predictors`.
Instead of numbers, variables in the data set can also be passed
allowing for varying truncation points across observations. Defining
only one of the two arguments in `trunc` leads to one-sided truncation.

#### Families: all continuous families

Missing values can be imputed using the `mi` function. See more details
with `mi` predictor terms.

#### Multivariate models

For multivariate models, `subset` may be used in the aterms part, to use
different subsets of the data in different univariate models. For
instance, if sub is a logical variable and y is the response of one of
the univariate models, we may write `y | subset(sub) ~ predictors` so
that y is predicted only for those observations for which sub evaluates
to TRUE.

#### Families: non-linear

<!-- TODO -->

### pterms

`response | aterms ~ pterms + (gterms | group)`

pterms defines the effects that are assumed to be the same across
observations, “population-level” “overall” effects.

#### pterms: non-linear

Flexible non-linear smooth terms can be modeled using the
[`s`](https://paul-buerkner.github.io/brms/reference/s.html) and
[`t2`](https://paul-buerkner.github.io/brms/reference/s.html) functions.
This allows to fit generalized additive mixed models (GAMMs) with
`brms.` The implementation is similar to that used in the `gamm4`
package. For more details on this model class see `gam` and `gamm`.

#### pterms: gaussian process

Gaussian process terms can be fitted using the
[`gp`](https://paul-buerkner.github.io/brms/reference/gp.html) function.
Similar to smooth terms, Gaussian processes can be used to model complex
non-linear relationships, for instance temporal or spatial
autocorrelation. However, they are computationally demanding and are
thus not recommended for very large datasets.

#### pterms: monotonic

Defined using the function
[`mo()`](https://paul-buerkner.github.io/brms/reference/mo.html),
e.g. `mo(predictor)`.

A monotonic predictor must either be integer valued or an ordered
factor. Predictor categories (or integers) are not assumed to be
equidistant with respect to their effect on the response variable.
Instead, the distance between adjacent predictor categories (or
integers) is estimated from the data and may vary across categories.
This is realized by parameterizing as follows: One parameter takes care
of the direction and size of the effect similar to an ordinary
regression parameter, while an additional parameter vector estimates the
normalized distances between consecutive predictor categories. A main
application of monotonic effects are ordinal predictors that can this
way be modeled without (falsely) treating them as continuous or as
unordered categorical predictors. For more details and examples see
[`vignette("brms_monotonic")`](https://paul-buerkner.github.io/brms/articles/brms_monotonic.html).

#### pterms: measurement error

Defined using the function
[`me()`](https://paul-buerkner.github.io/brms/reference/me.html)
e.g. `me(predictor, sd_predictor)`.

E.g. if y is the response variable and x is a measured predictor with
known measurement error sdx, `y ~ me(x, sdx)`. E.g. if x2 is another
measured predictor with corresponding error sdx2 and z is a predictor
without error (e.g., an experimental setting),
`y ~ me(x, sdx) * me(x2, sdx2) * z`. The me function is soft deprecated
in favor of the more flexible and consistent mi function (see below).

#### pterms: missing values

Defined using the function
[`mi()`](https://paul-buerkner.github.io/brms/reference/mi.html),
e.g. `mi(predictor)`.

When a variable contains missing values, the corresponding rows will be
excluded from the data by default (row-wise exclusion). However, quite
often we want to keep these rows and instead estimate the missing
values. There are two approaches for this: (a) Impute missing values
before the model fitting for instance via multiple imputation (see
[brm_multiple](https://paul-buerkner.github.io/brms/reference/brm_multiple.html)
for a way to handle multiple imputed datasets). (b) Impute missing
values on the fly during model fitting. For (b), we need to specify that
the predictor contains missings that should be imputed. E.g. if y is the
response, x is a predictor with missings and z is a predictor without
missings, then `y ~ mi(x) + z`. Second we need to model x as an
additional response with corresponding predictors and the addition term
`mi()`. E.g. `x | mi() ~ z`. Measurement error may be included via the
`sdy` argument, say, `x | mi(sdy = se) ~ z`. See mi for examples with
real data.

#### pterms: category specific

The function `cs()`, e.g. `cs(predictor)`. Category specific effects can
only be estimated in ordinal models and are explained in more detail in
the package’s main vignette (brms overview).

### gterms and group level terms

`response | aterms ~ pterms + (gterms | group)`

gterms contain effects that are assumed to vary across grouping
variables specified in group, “group-level”, “varying” effects.

For more details in vignettes brms overview, brms multilevel.

#### Modeling without correlations

Instead of \| you may use \|\| in grouping terms to prevent correlations
from being modeled. Equivalently, the cor argument of the gr function
can be used for this purpose, for example, `(1 + x || g)` is equivalent
to `(1 + x | gr(g, cor = FALSE))`.

#### Modeling with correlations

It is possible to model different group-level terms of the same grouping
factor as correlated by using `|<ID>|` instead of `|`. All group-level
terms sharing the same ID will be modeled as correlated. E.g. the terms
`(1+x|i|g)` and `(1+z|i|g)`, correlations between the corresponding
group-level effects will be estimated. In the above example, i is not a
variable in the data but just a symbol to indicate correlations between
multiple group-level terms. Equivalently, the id argument of the gr
function can be used as well, for example, `(1 + x | gr(g, id = "i"))`.

Difference covariance matrices can be used if levels of the grouping
factor belong to different sub-populations. E.g.
`y ~ x + (1 | gr(subject, by = x)`. Different hyper-parameters of the
varying effects (in this case a varying intercept) for treatment and
control group will be estimated.

You can specify multi-membership terms using the `mm` function. Eg. a
multi-membership term with two members `(1 | mm(g1, g2))`, where g1 and
g2 specify the first and second member, respectively. If a covariate x
varies across the levels of the grouping-factors g1 and g2, we can save
the respective covariate values in the variables x1 and x2 and then
model the varying effect as `(1 + mmc(x1, x2) | mm(g1, g2))`.

#### gterms: monotonic, measurement error, missing values, category specific

See related pterms sections.

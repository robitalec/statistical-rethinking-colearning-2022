Homework Week 04
================
Alec L. Robitaille
2022-03-04

## Question 1

Marriage is a collider between age and happiness. If we include marriage
as a predictor, it will generate an association between age and
happiness.

![](../graphics/homework/h04_q01_dag-1.png)<!-- -->

    ## [1] "Model 1: Happiness ~ intercept[marriage index] + age"

    ## 
    ## Computed from 4000 by 960 log-likelihood matrix
    ## 
    ##          Estimate   SE
    ## elpd_loo  -1356.9 18.6
    ## p_loo         3.6  0.2
    ## looic      2713.8 37.3
    ## ------
    ## Monte Carlo SE of elpd_loo is 0.0.
    ## 
    ## All Pareto k estimates are good (k < 0.5).
    ## See help('pareto-k-diagnostic') for details.

    ## [1] "Model 2: Happiness ~ intercept + age"

    ## 
    ## Computed from 4000 by 960 log-likelihood matrix
    ## 
    ##          Estimate   SE
    ## elpd_loo  -1551.0 13.8
    ## p_loo         2.4  0.1
    ## looic      3102.0 27.6
    ## ------
    ## Monte Carlo SE of elpd_loo is 0.0.
    ## 
    ## All Pareto k estimates are good (k < 0.5).
    ## See help('pareto-k-diagnostic') for details.

    ## [1] "Compared"

    ##        elpd_diff se_diff
    ## model1    0.0       0.0 
    ## model2 -194.1      17.6

The PSIS LOO results indicating that the model that includes marriage
has more predictive power, it does not indicate that the causal
structure or potential confounds are correctly accounted for in the
model. Marriage status is a collider, creating a statistical association
between age and happiness, and when removed from the model, there is no
longer an association between these variables.

    ## [1] "Model 1: Happiness ~ intercept[marriage index] + age"

    ##           mean    sd  5.5% 94.5%      histogram
    ## sigma     0.99 0.023  0.96  1.03       ▁▁▅▇▅▂▁▁
    ## beta_age -0.75 0.111 -0.92 -0.57      ▁▁▂▅▇▅▂▁▁
    ## alpha[1] -0.24 0.063 -0.34 -0.13     ▁▁▁▃▇▇▅▂▁▁
    ## alpha[2]  1.26 0.085  1.12  1.39 ▁▁▁▁▂▃▇▇▅▂▁▁▁▁

    ## [1] "Model 2: Happiness ~ intercept + age"

    ##              mean    sd  5.5% 94.5%   histogram
    ## sigma     1.21580 0.027  1.17  1.26 ▁▁▁▂▅▇▇▃▁▁▁
    ## beta_age  0.00180 0.131 -0.21  0.21  ▁▁▁▃▇▇▅▁▁▁
    ## alpha    -0.00078 0.076 -0.12  0.12  ▁▁▂▅▇▇▅▂▁▁

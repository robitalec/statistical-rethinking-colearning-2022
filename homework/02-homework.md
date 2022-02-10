Homework Week 02
================
Alec L. Robitaille
2022-02-07

# Question 1

> Construct a linear regression of weight as predicted by height, using
> the adults (age 18 or greater) from the Howell1 dataset. The heights
> listed below were recorded in the !Kung census, but weights were not
> recorded for these individuals. Provide predicted weights and 89%
> compatibility intervals for each of these individuals. That is, fill
> in the table below, using model-based predictions.

![](../graphics/homework/predict_h02_q01-1.png)<!-- -->

# Question 2

> From the Howell1 dataset, consider only the people younger than 13
> years old. Estimate the causal association between age and weight.
> Assume that age influences weight through two paths. First, age
> influences height, and height influences weight. Second, age directly
> influences weight through age- related changes in muscle growth and
> body proportions. All of this implies this causal model (DAG):

![](../graphics/homework/dag_h02_q02-1.png)<!-- -->

    ## [1] "Variables to include to measure total effect of age on weight:"

    ##  {}

> Use a linear regression to estimate the total (not just direct) causal
> effect of each year of growth on weight. Be sure to carefully consider
> the priors. Try using prior predictive simulation to assess what they
> imply.

![](../graphics/homework/priors_h02_q02-1.png)<!-- -->

    ##    variable mean  q5 q95
    ## 1:    sigma  2.5 2.3 2.8
    ## 2:    alpha  7.4 6.9 8.0
    ## 3: beta_age  1.3 1.2 1.4

# Question 3

> Now suppose the causal association between age and weight might be
> different for boys and girls. Use a single linear regression, with a
> categorical variable for sex, to estimate the total causal effect of
> age on weight separately for boys and girls. How do girls and boys
> differ? Provide one or more posterior contrasts as a summary.

![](../graphics/homework/h02_q03_contrast-1.png)<!-- -->

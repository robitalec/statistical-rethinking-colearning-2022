# Statistical Rethinking 2022 notes

# Lecture 01

## Golems

* powerful
* no intent
* require careful instructinos

## Hypotheses - Process models - Statistical models


Hypotheses are vague. To work with them, we need to transform into process models

Process models are precise and causal. However, different process models can yield different or the same statistical model. 

Statistical models strictly examine associations, not causation. 

![](hypo-proces-stat-models.png)

## Null models

Unique, singular null models are not always feasible, eg. communities, networks and phylogenies.

## Drawing the Bayesian owl

1. Theoretical estimand (precisely defined in:)
2. Scientific causal models
3. Combine theoretical estimate and scientific causal models to build statistical models
4. Simulate scientific causal models to validate statistical models yield theoretical estimand
5. Analyse real data

## Why Bayesian?

* flexible
* express uncertainty at all levels
* direct solutions to measurement error and missing data
* focus on scientific models instead of navigating flowcharts of different models and test - use the same approach for different problems


## DAGs
Scientific insights = scientific causal models + statistical models

Causes are not found in the data, the data just has associations between variables

Even when the goal is descriptive, you need causal thinking to define how a sample differs from the population

Causal inference is the prediction of intervention
* predict the consequences of an intervention
* "What if I do this?"

Causal imputation is 
* being able to construct unobserved counterfactual outcomes
* "What if I had done something else?"

DAGs are heuristic causal models and help with
* deciding which variables to include
* determining how to test a causal model
* identifying bad controls


# Lecture 02

## Bayesian data analysis


**For each possible explanation of the data, count all the ways the data can happen. Explanations with more ways to produce the data are more plausible.**


## Misc

Area under the curve = 1 because it is normalized 

1. No minimum sample size
2. Shape embodies samplen size
3. No point estimates since the distribution is the estimate (always use the entire distribution)
4. No one true interval

## Using a posterior

A model's behaviour is a function of all of its parameters at the same time, therefore you can't just gaze at tables of parameters

* posterior predictive simulation
* model based forecasts
* causal effects
* counterfactuals
* prior predictions


# Statistical Rethinking 2022 - Lecture 08

## Computing the posterior

1. Analytical approach
1. Grid approximation
1. Quadratic approximation (limited)
1. MCMC (intensive)

## King Markov

Eg. King Markov has a contract with citizens, to visit each island relative 
to its population size. 

1. Flip a coin to move left/right = proposal island
1. Find population of proposal island
1. Find population of current island
1. Move with probability population proposal / population current
1. Repeat

Over the long run, this will ensure that each island is visited proportionally
to the population. 

Markov chain: sequence of draws from the distribution, not dependent on 
long term history. 

Monte Carlo: random simulation

## History

MANIAC: Mathematical analyzer, numerical integrator, and computer

Estimation methods use gradients. Many newer and more efficient algorithms
but the initial method was developed by Rosenbluth/Metropolis. It requires
fine tuning the step size. Hamiltonian methods use a frictionless physics 
simulation. Calculation of gradients requires a derivative for each
parameter of the log posterior probability. Solution: auto differentiation
to automatically solve derivatives. Matrix of derivatives for each parameter
is called a Jacobian matrix. 

## Stan models

A benefit of Stan models is portability. All Stan models, regardless of which
scripting language is used, are the same. 


### Stan model blocks

More information here: https://mc-stan.org/docs/2_29/reference-manual/blocks.html

- Data: input data, eg. vector of age. Can set data type, constraints and lengths. 
- Parameters: unobserved variables, model parameters, eg. beta, sigma. Can set 
types and constraints. 
- Transformed parameters: transformed model parameters, will be returned in output. 
- Model: distributional poarts of the model sufficient to compute the posterior
probability
- Generated quantities: additional returned variables, eg. the log likelihood
for PSIS LOO. 



```
data {

...

}

parameters {

...


}

transformed parameters {

...

}

model {

...

}

generated quantities {

...

}
```

## Diagnostics

### Trace plots

Plot sequential sampels for each parameter. Sometimes, the warmup region 
is included showing Stan setting the step size and adapt delta settings. 

Healthy chains look: 

- relatively stationary
- no large drifting up or down
- multiple chains converge on the same distribution

"like a hairy caterpillar"


### Trace rank / trank plots

Sequential samples converted to ranks to evaluate if any chain is consistently
above or below the others


### R-hat

1. Start and end of each chain explores the same region
1. Independent chains explore the same region

R-hat is a ratio of variance for total variance across chains and within 
chains. It should approach 1. 

R-hat is not a test, just a diagnostic criterion.



### N-eff

Number of effective samples

When samples are autocorrelated, you have fewer effective samples. This is a 
measure of sampling efficiency. 


### Divergent transitions

Divergent transitions are rejected proposals. Many divergent transitions 
indicate poor exploration or possible bias. Computational problems 
often indicate a problem with the model.
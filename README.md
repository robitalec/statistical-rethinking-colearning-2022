Statistical Rethinking colearning 2022
================

-   [Schedule](#schedule)
-   [Resources](#resources)
-   [Installation](#installation)
-   [Project structure](#project-structure)
-   [Branches](#branches)
-   [Thanks](#thanks)
-   [Code of Conduct](#code-of-conduct)

------------------------------------------------------------------------

This repository contains resources and information for a colearning
group meeting regularly to discuss lectures and homework assignments
from the [Statistical Rethinking
2022](https://github.com/rmcelreath/stat_rethinking_2022) course.

## Schedule

Adjusting from Richard’s schedule for our pace. Note these are meeting
dates indicating when lectures, readings and homework are **assigned**,
to be discussed on/completed by the next meeting.

| Meeting date | Lectures                                                                                                                                                                       | Reading             | Homework                                                                                       |
|--------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|------------------------------------------------------------------------------------------------|
| 2022-01-13   | [(1) The Golem of Prague](https://youtu.be/cclUd_HoRlo), [(2) Bayesian Inference](https://www.youtube.com/watch?v=guTdrfycW2Q&list=PLDcUM9US4XdMROZ57-OIRtIK0aOynbgZN&index=2) | Chapters 1, 2 and 3 | [Homework 1](https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week01.pdf) |
| 2022-01-26   | [(3) Basic Regression](https://www.youtube.com/watch?v=zYYBtxHWE0A), [(4) Categories & Curves](https://youtu.be/QiHKdvAbYII)                                                   | Chapter 4           | [Homework 2](https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week02.pdf) |
| 2022-02-11   | [(5) Confounding](https://youtu.be/UpP-_mBvECI), [(6) Even Worse Confounding](https://www.youtube.com/watch?v=NSuTaeW6Orc)                                                     | Chapters 5 and 6    | [Homework 3](https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week03.pdf) |
| 2022-02-24   | [(7) Overfitting](https://www.youtube.com/watch?v=odGAAJDlgp8&list=PLDcUM9US4XdMROZ57-OIRtIK0aOynbgZN&index=7)                                                                 | Chapter 7           | [Homework 4](https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week04.pdf) |

## Resources

-   Lectures:
    <https://github.com/rmcelreath/stat_rethinking_2022#calendar--topical-outline>
-   Homework:
    <https://github.com/rmcelreath/stat_rethinking_2022/tree/main/homework>

Additional material using other packages or languages

-   Original R: <https://github.com/rmcelreath/rethinking/>
-   R + Tidyverse + ggplot2 + brms: <https://bookdown.org/content/4857/>
-   Python and PyMC3: Python/PyMC3
-   Julia and Turing: <https://github.com/StatisticalRethinkingJulia>
    and <https://github.com/StatisticalRethinkingJulia/TuringModels.jl>

See Richard’s comments about these here:
<https://github.com/rmcelreath/stat_rethinking_2022#original-r-flavor>

Also, Alec’s notes and solutions of the 2019 material:
<https://github.com/robitalec/statistical-rethinking> and
<https://www.statistical-rethinking.robitalec.ca/>

## Installation

Package specific install directions. We’ll update these as we go!

Rethinking

-   [`rethinking`](https://github.com/rmcelreath/rethinking#installation)

Stan

-   [`cmdstanr`](https://mc-stan.org/cmdstanr/articles/cmdstanr.html)
-   [`RStan`](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started)
-   [`brms`](r/brms/#how-do-i-install-brms)

Targets

-   [`targets`](https://github.com/ropensci/targets/#installation)
-   [`stantargets`](https://github.com/ropensci/stantargets/#installation)

V8, needed for the `dagitty` package

-   [`V8`](https://github.com/jeroen/v8#installation)

## Project structure

This repository is structured with a `homework/` folder for homework
solutions, and `notes/` folder for notes. For folks joining in the
colearning group, you are encouraged to make your own branch in this
repository and share your notes and/or homework solutions.

The `R/` folder can be used to store reusable functions useful across
homework solutions and your own model situations.

For example, the `dag_plot` function makes a DAG plot from a DAG:

``` r
library(ggplot2)
library(ggdag)
```

    ## 
    ## Attaching package: 'ggdag'

    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

``` r
library(dagitty)

source('R/dag_plot.R')

dag <- dagify(
    Z ~ A + B,
    B ~ A,
    exposure = 'A',
    outcome = 'Z'
)

dag_plot(dag)
```

![](graphics/readme_dag-1.png)<!-- -->

## Branches

See the full list of
[branches](https://github.com/robitalec/statistical-rethinking-colearning-2022/branches).

-   [Matteo](https://github.com/robitalec/statistical-rethinking-colearning-2022/tree/matteo)
-   [Jillian](https://github.com/robitalec/statistical-rethinking-colearning-2022/tree/jillian)
-   [Alec](https://github.com/robitalec/statistical-rethinking-colearning-2022/tree/alec)
-   [Levi](https://github.com/robitalec/statistical-rethinking-colearning-2022/tree/levi)
-   [Katrien](https://github.com/robitalec/statistical-rethinking-colearning-2022/tree/katrien)
-   [Bella](https://github.com/robitalec/statistical-rethinking-colearning-2022/tree/bella)
-   [Hannah](https://github.com/robitalec/statistical-rethinking-colearning-2022/tree/hannah)
-   [Frankie](https://github.com/robitalec/statistical-rethinking-colearning-2022/tree/frankie)

## Thanks

Many thanks to Richard McElreath for a continued emphasis on teaching
Bayesian statistics and for providing this incredible resource of
lectures and homework assignments free for everyone.

Also thank you to the developers of R, Stan and innumerous R packages
that allow us to pursue this interest.

## Code of Conduct

Please note that this project is released with a [Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

library(dagitty)
library(ggdag)

source('R/dag_plot.R')

dag <- dagify(
  Weight ~ Age + Height,
  Height ~ Age,
  exposure = 'Age',
  outcome = 'Weight'
)

dag_plot(dag)


adjustmentSets(dag, effect = 'total')
adjustmentSets(dag, effect = 'direct')

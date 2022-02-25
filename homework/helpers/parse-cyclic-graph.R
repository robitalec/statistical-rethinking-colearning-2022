# Based off the Discussion in:
# Greenland, Sander, Judea Pearl, and James M. Robins. "Causal diagrams for epidemiologic research." Epidemiology (1999): 37-48.
# http://ftp.cs.ucla.edu/pub/stat_ser/r251.pdf

# Directed Cyclic Graph - since there is a feedback loop between erosion and slope
cyclic <- dagify(
  Erosion ~ Slope + Rain + Veg_loss,
  Veg_loss ~ Erosion,
  exposure = 'Slope',
  outcome = 'Erosion'
)

dag_plot(cyclic, 'graphics/erosion')

# Parse feedback loops into temporal variables = Directed Acyclic Graph
acyclic <- dagify(
  Veg_loss_t2 ~ Erosion_t1 + Veg_loss_t1,
  Erosion_t2 ~ Erosion_t1 + Slope + Rain + Veg_loss_t1,
  exposure = 'Slope',
  outcome = 'Erosion_t2'
)

dag_plot(acyclic, 'graphics/erosion-t')

adjustmentSets(acyclic, effect = 'direct')

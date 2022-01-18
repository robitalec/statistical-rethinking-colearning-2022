# install rstan
## remove potential prior installations
remove.packages("rstan")
if (file.exists(".RData")) file.remove(".RData")
## install rstan 
install.packages("rstan", repos = "https://cloud.r-project.org/", dependencies = TRUE)
## test
example(stan_model, package = "rstan", run.dontrun = TRUE)

# install CmdStan
# we recommend running this is a fresh R session or restarting your current session
install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))

# install rethinking and other packages required
install.packages(c("coda", "mvtnorm", "devtools", "dagitty"))
library(devtools)
devtools::install_github("rmcelreath/rethinking")
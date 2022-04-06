# === Targets -------------------------------------------------------------
# Alec L. Robitaille



# Source ------------------------------------------------------------------
lapply(dir('R', '*.R', full.names = TRUE), source)



# Options -----------------------------------------------------------------
# Targets
tar_option_set(format = 'qs',
               workspace_on_error = TRUE)


# Variables ---------------------------------------------------------------
# Stan model, compiled dir
model_dir_stan <- file.path('stan')
compiled_dir <- file.path('stan', 'compiled')
output_stan_dir <- file.path('stan', 'output')
stan_files <- dir(model_dir_stan, '.stan', full.names = TRUE)

# cpp_options = list(stan_threads = TRUE),
# chains = 4,
# quiet = FALSE,
# parallel_chains = 4,
# threads_per_chain = 4,
# dir = compiled_dir,
# output_dir = output_stan_dir



# Homework ----------------------------------------------------------------
source(file.path('homework', '05-homework-targets.R'))

# Targets: all ------------------------------------------------------------
# Automatically grab all the "targets_*" lists above
lapply(grep('targets', ls(), value = TRUE), get)
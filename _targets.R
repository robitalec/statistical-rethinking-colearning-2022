# === Targets -------------------------------------------------------------
# Alec L. Robitaille



# Source ------------------------------------------------------------------
lapply(dir('R', '*.R', full.names = TRUE), source)



# Options -----------------------------------------------------------------
# Targets
tar_option_set(format = 'qs',
               workspace_on_error = TRUE)


# Variables ---------------------------------------------------------------


# Homework ----------------------------------------------------------------
source(file.path('homework', '06-homework-targets.R'))

# Targets: all ------------------------------------------------------------
# Automatically grab all the "targets_*" lists above
lapply(grep('targets', ls(), value = TRUE), get)

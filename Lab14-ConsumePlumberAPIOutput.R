# *****************************************************************************
# Lab 14: Consume data from the Plumber API Output (using R) ----
#
# Course Code: BBT4206
# Course Name: Business Intelligence II
# Semester Duration: 21st August 2023 to 28th November 2023
#
# Lecturer: Allan Omondi
# Contact: aomondi [at] strathmore.edu
#
# Note: The lecture contains both theory and practice. This file forms part of
#       the practice. It has required lab work submissions that are graded for
#       coursework marks.
#
# License: GNU GPL-3.0-or-later
# See LICENSE file for licensing information.
# *****************************************************************************

# **[OPTIONAL] Initialization: Install and use renv ----
# The R Environment ("renv") package helps you create reproducible environments
# for your R projects. This is helpful when working in teams because it makes
# your R projects more isolated, portable and reproducible.

# Further reading:
#   Summary: https://rstudio.github.io/renv/
#   More detailed article: https://rstudio.github.io/renv/articles/renv.html

# "renv" It can be installed as follows:
# if (!is.element("renv", installed.packages()[, 1])) {
# install.packages("renv", dependencies = TRUE,
# repos = "https://cloud.r-project.org") # nolint
# }
# require("renv") # nolint

# Once installed, you can then use renv::init() to initialize renv in a new
# project.

# The prompt received after executing renv::init() is as shown below:
# This project already has a lockfile. What would you like to do?

# 1: Restore the project from the lockfile.
# 2: Discard the lockfile and re-initialize the project.
# 3: Activate the project without snapshotting or installing any packages.
# 4: Abort project initialization.

# Select option 1 to restore the project from the lockfile
# renv::init() # nolint

# This will set up a project library, containing all the packages you are
# currently using. The packages (and all the metadata needed to reinstall
# them) are recorded into a lockfile, renv.lock, and a .Rprofile ensures that
# the library is used every time you open the project.

# Consider a library as the location where packages are stored.
# Execute the following command to list all the libraries available in your
# computer:
.libPaths()

# One of the libraries should be a folder inside the project if you are using
# renv

# Then execute the following command to see which packages are available in
# each library:
lapply(.libPaths(), list.files)

# This can also be configured using the RStudio GUI when you click the project
# file, e.g., "BBT4206-R.Rproj" in the case of this project. Then
# navigate to the "Environments" tab and select "Use renv with this project".

# As you continue to work on your project, you can install and upgrade
# packages, using either:
# install.packages() and update.packages or
# renv::install() and renv::update()

# You can also clean up a project by removing unused packages using the
# following command: renv::clean()

# After you have confirmed that your code works as expected, use
# renv::snapshot(), AT THE END, to record the packages and their
# sources in the lockfile.

# Later, if you need to share your code with someone else or run your code on
# a new machine, your collaborator (or you) can call renv::restore() to
# reinstall the specific package versions recorded in the lockfile.

# [OPTIONAL]
# Execute the following code to reinstall the specific package versions
# recorded in the lockfile (restart R after executing the command):
# renv::restore() # nolint

# [OPTIONAL]
# If you get several errors setting up renv and you prefer not to use it, then
# you can deactivate it using the following command (restart R after executing
# the command):
# renv::deactivate() # nolint

# If renv::restore() did not install the "languageserver" package (required to
# use R for VS Code), then it can be installed manually as follows (restart R
# after executing the command):

if (require("languageserver")) {
  require("languageserver")
} else {
  install.packages("languageserver", dependencies = TRUE,
                   repos = "https://cloud.r-project.org")
}

# STEP 1. Install and load the required packages ----
## httr ----
if (require("httr")) {
  require("httr")
} else {
  install.packages("httr", dependencies = TRUE,
                   repos = "https://cloud.r-project.org")
}

## jsonlite ----
if (require("jsonlite")) {
  require("jsonlite")
} else {
  install.packages("jsonlite", dependencies = TRUE,
                   repos = "https://cloud.r-project.org")
}

# STEP 2. Generate the URL required to access the API ----

# We set this as a constant port 5022 running on localhost
base_url <- "http://127.0.0.1:5022/diabetes"

# We create a named list called "params".
# It contains an element for each parameter we need to specify.
params <- list(arg_pregnant = 6, arg_glucose = 148, arg_pressure = 72,
               arg_triceps = 35, arg_insulin = 0, arg_mass = 33.6,
               arg_pedigree = 0.627, arg_age = 50)

query_url <- httr::modify_url(url = base_url, query = params)

# This is how the URL looks
# Note: You can go to the URL using a browser and as long as the API is running,
# you will get a response.
print(query_url)

# STEP 3. Make the request for the model prediction through the API ----
# The results of the model prediction through the API can also be obtained in R
model_prediction <- GET(query_url)

# Notice that the result displays additional JSON content, e.g., [[1]]
content(model_prediction)

# We can print the specific result as follows:
content(model_prediction)[[1]]

# However, the response still has some JSON content.

# STEP 4. Parse the response into the right format ----
# We need to extract the results from the default JSON list format into
# a non-list text format:
model_prediction_raw <- content(model_prediction, as = "text",
                                encoding = "utf-8")
jsonlite::fromJSON(model_prediction_raw)

# STEP 5. Enclose everything in a function ----
# All the 3 steps above can be enclosed in a function
get_diabetes_predictions <-
  function(arg_pregnant, arg_glucose, arg_pressure, arg_triceps,
           arg_insulin, arg_mass, arg_pedigree, arg_age) {
    base_url <- "http://127.0.0.1:5022/diabetes"

    params <- list(arg_pregnant = arg_pregnant, arg_glucose = arg_glucose,
                   arg_pressure = arg_pressure, arg_triceps = arg_triceps,
                   arg_insulin = arg_insulin, arg_mass = arg_mass,
                   arg_pedigree = arg_pedigree, arg_age = arg_age)

    query_url <- modify_url(url = base_url, query = params)

    model_prediction <- GET(query_url)

    model_prediction_raw <- content(model_prediction, as = "text",
                                    encoding = "utf-8")

    jsonlite::fromJSON(model_prediction_raw)
  }

# The model's prediction should be "positive for diabetes" based on the
# following parameters:
get_diabetes_predictions(6, 148, 72, 35, 0, 33.6, 0.627, 50)

# The model's prediction should be "negative for diabetes" based on the
# following parameters:
get_diabetes_predictions(1, 85, 66, 29, 0, 26.6, 0.351, 31)

# [OPTIONAL] **Deinitialization: Create a snapshot of the R environment ----
# Lastly, as a follow-up to the initialization step, record the packages
# installed and their sources in the lockfile so that other team-members can
# use renv::restore() to re-install the same package version in their local
# machine during their initialization step.
# renv::snapshot() # nolint
################################################################################################################################
## This is a helper program to download Daymet data via the NASA AppEEARS API.                                                ##
## The user will need to create a NASA EarthData account first, if they don't yet have one.                                   ##
## A NASA EarthData account can be created here: https://urs.earthdata.nasa.gov/.                                             ##
## The user can specify the variable(s), year(s), and bounding box of Daymet data to download.                                ##
## This downloaded Daymet data can then be linked with geocoded healthcare encounters via the Daymet DeGAUSS tool.            ##
## Ensure that this helper program is being run within the same working directory as the healthcare encounter data.           ##
################################################################################################################################

################################################################################################################################
## Uncomment the code below and install the required packages if needed.                                                      ##
#install.packages("appeears")
#install.packages("tidyverse")
#install.packages("terra")
#install.packages("getPass")
################################################################################################################################

################################################################################################################################
## Set the parameters for the Daymet data of interest.                                                                        ##

## Specify the Daymet variable(s): Any combination of c("dayl", "prcp", "srad", "swe", "tmax", "tmin", "vp")                  ##
layers <- c("dayl", "prcp", "srad", "swe", "tmax", "tmin", "vp")

## Specify the year(s) of Daymet data needed (1980 [1950 for Puerto Rico] to previous year): c(YYYY, YYYY, YYYY, ...)         ##
years <- c(1980, 2024)

## Specify the bounding box coordinates of Daymet data to download: maximum/minimum latitude and longitude as decimal degrees ##
maximum_latitude <- 42.154247
minimum_latitude <- 41.470117
maximum_longitude <- -87.525706
minimum_longitude <- -88.263390

## After the parameters have been set, run the entire helper program:                                                         ##
## Click 'Source' in the upper-right if in RStudio, or run: source("appeears_daymet.R")                                       ##
## DO NOT EDIT CODE BELOW THIS LINE                                                                                           ##
################################################################################################################################

# Loading necessary packages
library(appeears)
library(tidyverse)
library(terra)
library(getPass)

# Specifying file-based keyring, creating appeears keyring if necessary, and unlocking appeears keyring
keyring_name <- "appeears"
options(keyring_backend = "file")
if (!keyring_name %in% keyring::keyring_list()$keyring) {
  username <- getPass("Enter your NASA EarthData username: ")
  pw <- getPass("Enter your NASA EarthData password: ")
  rs_set_key(
    user = username,
    password = pw)
} else {
  earthdata_account_locked <- keyring::keyring_is_locked(keyring = keyring_name)
  while (earthdata_account_locked) {
    tryCatch({
      pw <- getPass("Enter your NASA EarthData password: ")
      keyring::keyring_unlock(keyring = keyring_name, password = pw)
      username <- keyring::key_list(keyring = keyring_name)$username
      earthdata_account_locked <- keyring::keyring_is_locked(keyring = keyring_name)
      message("Log in successful.")
    }, error = function(e) {
      message("NASA EarthData password incorrect.")
    })
  }
}

# Listing all EarthData products
products <- rs_products()

# Subsetting to Daymet product
daymet <- subset(products, Product == "DAYMET")
daymet <- daymet$ProductAndVersion

# Checking Daymet parameters specified by user
# Daymet variable(s)
layers <- str_remove_all(layers, " ")
available_layers <- rs_layers(daymet)
available_layers <- unname(unlist(available_layers$Layer))
if (!all(layers %in% available_layers)) {
  layers <- available_layers
  message("Invalid input for Daymet variable specification. Will return all Daymet variables. Please see https://degauss.org/daymet/ for more information.")
}

# Daymet year(s)
if (!is.numeric(years)) {
  stop(call. = FALSE, "Input for year(s) of Daymet data needed specification must be numeric. Please see https://degauss.org/daymet/ for more information.")
}
if (any(!str_detect(as.character(years), "^\\d{4}$"))) {
  stop(call. = FALSE, "Input for year(s) of Daymet data needed specification must be four-digit year(s) (e.g.: 2000). Please see https://degauss.org/daymet/ for more information.")
}
if (!all(between(years, 1950, year(Sys.Date()) - 1))) {
  stop(call. = FALSE, "Input for year(s) of Daymet data needed specification must be within the range of available Daymet data: From 1950 for Puerto Rico data or 1980 otherwise To the previous calendar year. Please see https://degauss.org/daymet/ for more information.")
}

# Daymet bounding box coordinates
if (!is.numeric(maximum_latitude) | !is.numeric(minimum_latitude) | !is.numeric(maximum_longitude) | !is.numeric(minimum_longitude)) {
  stop(call. = FALSE, "Input for bounding box coordinates of Daymet data to download specification must be numeric decimal degrees. Please see https://degauss.org/daymet/ for more information.")
}
if (!(minimum_latitude < maximum_latitude)) {
  stop(call. = FALSE, paste0("Please ensure that bounding box minimum_latitude: ", minimum_latitude,
                             " is less than bounding box maximum_latitude: ", maximum_latitude, "."))
}
if (!(minimum_longitude < maximum_longitude)) {
  stop(call. = FALSE, paste0("Please ensure that bounding box minimum_longitude: ", minimum_longitude,
                             " is less than bounding box maximum_longitude: ", maximum_longitude, "."))
}

# Creating a SpatRaster ROI from bounding box coordinates
roi <- rast(xmin = minimum_longitude, xmax = maximum_longitude, ymin = minimum_latitude, ymax = maximum_latitude, crs = "EPSG:4326")

# Building one area-based request/task per year per layer
years_layers <- expand_grid(year = years, layer = layers)
request_list <- map2(years_layers$year, years_layers$layer, ~ {
  df <- data.frame(
    task = paste0(.x, "_", .y),
    subtask = "Daymet",
    latitude = 0,
    longitude = 0,
    start = paste0(.x, "-01-01"),
    end = paste0(.x, "-12-31"),
    product = daymet,
    layer = .y)
  rs_build_task(
    df = df,
    roi = roi,
    format = "netcdf4")
})

# Requesting all tasks to be executed and downloading files
dir.create("Daymet_Data")
transfer_task_ids <- list()
for (i in 1:length(request_list)) {
  skip_to_next <- FALSE
  msg <- character()
  tryCatch(
    withCallingHandlers(
      rs_request(
        request = request_list[[i]],
        user = username,
        transfer = TRUE,
        path = paste0(getwd(), "/Daymet_Data"),
        verbose = TRUE),
      message = function(m) {
        msg <<- c(msg, conditionMessage(m))
      }),
    error = function(e) {
      msg <<- paste(msg, collapse = " ")
      msg <<- str_extract(msg, "(?s)(?<=task id:)(.*)(?=- timeout)")
      msg <<- str_trim(msg)
      name <- paste0(years_layers[i, "year"], "_", years_layers[i, "layer"])
      transfer_task_ids[[name]] <<- msg
      message(paste0("Download for ", years_layers[i, "year"], "_", years_layers[i, "layer"], " failed. Will try transferring data from EarthData AppEEARS site."))
      skip_to_next <<- TRUE
    })
  if (skip_to_next) {
    next
  }
}
if (length(transfer_task_ids) > 0) {
  for (i in 1:length(transfer_task_ids)) {
    task_status <- rs_list_task(task_id = transfer_task_ids[[i]], user = username)$status
    while (task_status != "done") {
      message(paste("Pausing 1 minute to allow EarthData AppEEARS site Request", transfer_task_ids[[i]], "to finish processing (Status of done) before attempting data transfer."))
      Sys.sleep(60)
      task_status <- rs_list_task(task_id = transfer_task_ids[[i]], user = username)$status
      message(paste("Checking again... current Status =", task_status))
    }
    new_dir <- paste0("Daymet_Data/", names(transfer_task_ids)[i])
    dir.create(new_dir)
    rs_transfer(task_id = transfer_task_ids[[i]],
                user = username,
                path = paste0(getwd(), "/", new_dir),
                verbose = TRUE)
    rs_delete(task_id = transfer_task_ids[[i]], user = username)
  }
}

# Logging out of current session token
token <- rs_login(user = username)
rs_logout(token)
rm(list = ls())
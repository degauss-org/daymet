#!/usr/local/bin/Rscript

# Greeting users
dht::greeting()

# Loading libraries without messages or warnings
withr::with_message_sink("/dev/null", library(tidyverse))
withr::with_message_sink("/dev/null", library(terra))
withr::with_message_sink("/dev/null", library(gtools))
withr::with_message_sink("/dev/null", library(data.table))
withr::with_message_sink("/dev/null", library(dht))
withr::with_message_sink("/dev/null", library(appeears))

doc <- '
      Usage:
      entrypoint.R <filename> [--vars=<vars>] [--min_lat=<min_lat>] [--max_lat=<max_lat>] [--min_lon=<min_lon>] [--max_lon=<max_lon>] [--delete_daymet]
      entrypoint.R (-h | --help)

      Options:
      -h --help  Show this screen
      filename  Name of input CSV file
      --vars=<vars>  Daymet variables (see readme for more info) [default: dayl, prcp, srad, swe, tmax, tmin, vp]
      --min_lat=<min_lat>  Minimum latitude of bounding box [default: NA]
      --max_lat=<max_lat>  Maximum latitude of bounding box [default: NA]
      --min_lon=<min_lon>  Minimum longitude of bounding box [default: NA]
      --max_lon=<max_lon>  Maximum longitude of bounding box [default: NA]
      --delete_daymet  Delete downloaded Daymet data
      '
opt <- docopt::docopt(doc)

# Writing functions
# Creating function to import the input data
import_data <- function(.csv_filename = opt$filename, .min_lat = opt$min_lat, .max_lat = opt$max_lat, .min_lon = opt$min_lon, .max_lon = opt$max_lon) {
  # Checking that the input data is a CSV file
  if (!str_detect(.csv_filename, "\\.csv$")) {
    stop(call. = FALSE, 'Input file must be a CSV.')
  }
  # Reading in the input data
  input_data <- fread(.csv_filename, header = TRUE, sep = ",", colClasses = c(id = "character", start_date = "character", end_date = "character"))
  input_data <- as_tibble(input_data)
  # Creating a row_index variable in the input data that is just the row number
  input_data <- input_data %>%
    mutate(row_index = 1:nrow(input_data)) %>%
    relocate(row_index)
  # Ensuring that an id column is in the input data, and quitting if not
  tryCatch({
    check_for_column(input_data, column_name = "id")
  }, error = function(e) {
    print(e)
    stop(call. = FALSE)
  }, warning = function(w) {
    print(w)
    stop(call. = FALSE)
  })
  # Ensuring that numeric lat and lon are in the input data, and quitting if not
  tryCatch({
    check_for_column(input_data, column_name = "lat")
    check_for_column(input_data, column_name = "lon")
    check_for_column(input_data, column_name = "lat", column = input_data$lat, column_type = "numeric")
    check_for_column(input_data, column_name = "lon", column = input_data$lon, column_type = "numeric")
  }, error = function(e) {
    print(e)
    stop(call. = FALSE)
  }, warning = function(w) {
    print(w)
    stop(call. = FALSE)
  })
  # Filtering out rows in the input data where lat or lon are missing
  input_data <- input_data %>%
    filter(!is.na(lat) & !is.na(lon))
  # Throwing an error if no observations are remaining
  if (nrow(input_data) == 0) {
    stop(call. = FALSE, 'Zero observations where lat and lon are not missing.')
  }
  # Verifying that if the user supplied bounding box coordinates, they consist of numeric coordinates
  if (!(.min_lat == "NA" & .max_lat == "NA" & .min_lon == "NA" & .max_lon == "NA")) {
    tryCatch({
      .min_lat <- as.numeric(.min_lat)
      .max_lat <- as.numeric(.max_lat)
      .min_lon <- as.numeric(.min_lon)
      .max_lon <- as.numeric(.max_lon)
    }, error = function(e) {
      print(e)
      stop(call. = FALSE, 'Please ensure that user-supplied Daymet bounding box has all coordinates entered in numeric decimal degrees. Please see https://degauss.org/daymet/ for more information.')
    }, warning = function(w) {
      stop(call. = FALSE, 'Please ensure that user-supplied Daymet bounding box has all coordinates entered in numeric decimal degrees. Please see https://degauss.org/daymet/ for more information.')
    })
  }
  # Verifying that if the user supplied bounding box coordinates, the minimum coordinates are less than the maximum coordinates
  if (!(.min_lat == "NA" & .max_lat == "NA" & .min_lon == "NA" & .max_lon == "NA")) {
    if (!(.min_lat < .max_lat)) {
      stop(call. = FALSE, paste0('Please ensure that bounding box minimum latitude: ', .min_lat,
                                 ' is less than bounding box maximum latitude: ', .max_lat, '.'))
    }
    if (!(.min_lon < .max_lon)) {
      stop(call. = FALSE, paste0('Please ensure that bounding box minimum longitude: ', .min_lon,
                                 ' is less than bounding box maximum longitude: ', .max_lon, '.'))
    }
  }
  # If the user supplied bounding box coordinates, then removing observations where the address is outside of the bounding box of Daymet data
  if (!(.min_lat == "NA" & .max_lat == "NA" & .min_lon == "NA" & .max_lon == "NA")) {
    input_data <- input_data %>%
      filter(lat >= .min_lat & lat <= .max_lat & lon >= .min_lon & lon <= .max_lon)
  }
  # Throwing an error if no observations are remaining
  if (nrow(input_data) == 0) {
    stop(call. = FALSE, 'Zero observations where the lat and lon coordinates are within the user-supplied bounding box of Daymet data.')
  }
  # Ensuring that start_date and end_date are in the input data as dates, and quitting if not
  tryCatch({
    check_for_column(input_data, column_name = "start_date")
    check_for_column(input_data, column_name = "end_date")
    input_data$start_date <- check_dates(input_data$start_date, allow_missing = TRUE)
    input_data$end_date <- check_dates(input_data$end_date, allow_missing = TRUE)
  }, error = function(e) {
    print(e)
    stop(call. = FALSE)
  }, warning = function(w) {
    print(w)
    stop(call. = FALSE)
  })
  # Filtering out rows in the input data where start_date or end_date are missing
  input_data <- input_data %>%
    filter(!is.na(start_date) & !is.na(end_date))
  # Throwing an error if no observations are remaining
  if (nrow(input_data) == 0) {
    stop(call. = FALSE, 'Zero observations where the user-supplied event dates are not entirely missing.')
  }
  # Checking that end_date is after start_date
  tryCatch({
    check_end_after_start_date(input_data$start_date, input_data$end_date)
  }, error = function(e) {
    print(e)
    stop(call. = FALSE)
  }, warning = function(w) {
    print(w)
    stop(call. = FALSE)
  })
  # Expanding the dates between start_date and end_date into a daily series
  input_data <- expand_dates(input_data, by = "day") %>%
    select(-c(start_date, end_date))
  # Filtering out any rows in the input data where the date is not within the range of available Daymet data
  input_data <- input_data %>%
    filter(year(date) >= 1950 & year(date) < year(Sys.Date()))
  # Throwing an error if no observations are remaining
  if (nrow(input_data) == 0) {
    stop(call. = FALSE, 'Zero observations where the user-supplied event dates are within the range of available Daymet data: From 1950 for Puerto Rico data or 1980 otherwise To the previous calendar year. Please see https://degauss.org/daymet/ for more information.')
  }
  # Extracting the years needed for the Daymet data download
  years <- unique(year(input_data$date))
  years <- sort(years)
  # Removing any columns in the input data where everything is NA
  input_data <- input_data %>%
    select_if(~ !all(is.na(.)))
  # Returning a list of objects needed later
  out <- list("input_data" = input_data, "years" = years)
  return(out)
}

# Creating function to download the Daymet NetCDF data
daymet_download <- function(.layers = opt$vars, .years = years, .min_lat = opt$min_lat, .max_lat = opt$max_lat, .min_lon = opt$min_lon, .max_lon = opt$max_lon, .input_data = input_data) {
  # Creating a spoof appeears keyring
  if (!("appeears" %in% keyring::keyring_list()$keyring)) {
    keyring::keyring_create("appeears", password = "spoof")
  }
  # Setting the key via username and password passed as command line environmental variables
  username <- Sys.getenv("USER", unset = NA)
  pw <- Sys.getenv("PASSWORD", unset = NA)
  if (!is.na(username) & !is.na(pw)) {
    rs_set_key(
      user = username,
      password = pw)
  } else {
    stop(call. = FALSE, "NASA EarthData username and/or password not entered. Please see https://degauss.org/daymet/ for more information.")
  }
  # Listing all EarthData products
  products <- rs_products()
  # Subsetting to Daymet product
  daymet <- subset(products, Product == "DAYMET")
  daymet <- daymet$ProductAndVersion
  # Checking Daymet variable(s) specified by user
  if (.layers == "dayl, prcp, srad, swe, tmax, tmin, vp") {
    message("Blank or default argument for Daymet variable selection. Will return all Daymet variables. Please see https://degauss.org/daymet/ for more information.")
  }
  .layers <- str_remove_all(.layers, " ")
  .layers <- str_split(.layers, ",", simplify = TRUE)[1, ]
  available_layers <- rs_layers(daymet)
  available_layers <- unname(unlist(available_layers$Layer))
  if (!all(.layers %in% available_layers)) {
    .layers <- available_layers
    message("Invalid argument for Daymet variable selection. Will return all Daymet variables. Please see https://degauss.org/daymet/ for more information.")
  }
  # If the Daymet data bounding box was not supplied by the user, then inferring the bounding box from the input file coordinates
  if (.min_lat == "NA" & .max_lat == "NA" & .min_lon == "NA" & .max_lon == "NA") {
    message("Blank arguments for Daymet bounding box coordinates. Will use coordinates from input file. Please see https://degauss.org/daymet/ for more information.")
    # Finding the min and max latitude and longitude out of all the input file coordinates
    .min_lat <- min(.input_data$lat)
    .max_lat <- max(.input_data$lat)
    .min_lon <- min(.input_data$lon)
    .max_lon <- max(.input_data$lon)
    # In order to preserve privacy, adding a random amount of noise to the bounding box of input file coordinates
    # Each bounding box point (e.g., maximum latitude) will be extended by an additional 0.5-1.0 degrees
    noise <- runif(4, min = 0.5, max = 1.0)
    .min_lat <- .min_lat - noise[1]
    .max_lat <- .max_lat + noise[2]
    .min_lon <- .min_lon - noise[3]
    .max_lon <- .max_lon + noise[4]
  } else {
    .min_lat <- as.numeric(.min_lat)
    .max_lat <- as.numeric(.max_lat)
    .min_lon <- as.numeric(.min_lon)
    .max_lon <- as.numeric(.max_lon)
  }
  # Creating a SpatRaster ROI from bounding box coordinates
  roi <- terra::rast(xmin = .min_lon, xmax = .max_lon, ymin = .min_lat, ymax = .max_lat, crs = "EPSG:4326")
  # Building one area-based request/task per year per layer
  years_layers <- expand_grid(year = .years, layer = .layers)
  suppressMessages(request_list <- map2(years_layers$year, years_layers$layer, ~ {
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
  }))
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
          msg <<- paste(msg, collapse = " ")
          if (str_detect(msg, "Your download timed out")) {
            msg <<- str_extract(msg, "(?s)(?<=task id:)(.*)(?=- timeout)")
            msg <<- str_trim(msg)
            name <- paste0(years_layers[i, "year"], "_", years_layers[i, "layer"])
            transfer_task_ids[[name]] <<- msg
            message(paste0("Download for ", years_layers[i, "year"], "_", years_layers[i, "layer"], " timed out. Will try transferring data from EarthData AppEEARS site using the steps outlined below."))
          }
      }),
      error = function(e) {
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
  invisible(rs_logout(token))
}

# Creating function to load the downloaded Daymet NetCDF data
daymet_load <- function() {
  # Loading the Daymet NetCDF files as a SpatRaster raster stack
  daymet_folder_list <- list.dirs(path = "Daymet_Data", recursive = FALSE)
  # Checking for a NetCDF file in the Daymet subfolder, and skipping subfolder if one does not exist
  daymet_file_list <- character()
  for (i in 1:length(daymet_folder_list)) {
    netcdf <- list.files(path = daymet_folder_list[i], pattern = "\\.nc$")
    if (length(netcdf) > 0) {
      daymet_file_list <- c(daymet_file_list, daymet_folder_list[i])
    }
  }
  # Initializing a time dictionary
  time_dict <- tibble(number = 1:365)
  for (i in 1:length(daymet_file_list)) {
    # Extracting the year and Daymet variable from the subfolder of the NetCDF file to be loaded in
    yr <- str_extract(daymet_file_list[i], "[0-9]{4}")
    dm_var <- unlist(str_split(daymet_file_list[i], "_"))[3]
    # Creating a vector of layer names
    layer_names <- as.character(1:365)
    layer_names <- paste0(dm_var, "_", layer_names, "_", yr)
    # Loading the Daymet data
    netcdf <- list.files(path = daymet_file_list[i], pattern = "\\.nc$")
    daymet_load <- terra::rast(paste0(daymet_file_list[i], "/", netcdf))
    # Setting Daymet projection
    crs(daymet_load) <- "+proj=lcc +lat_1=25 +lat_2=60 +lat_0=42.5 +lon_0=-100 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs"
    names(daymet_load) <- layer_names
    # Creating a dictionary to link numbers 1–365 to a date in a year (time dictionary)
    origin <- as_date(paste0(yr, "-01-01")) - 1 # Numbers count days since origin
    time_dict <- time_dict %>%
      mutate(year = yr,
             date := as_date(number, origin = origin))
    # Stacking the Daymet data rasters and time dictionary, and tracking the year and Daymet variable
    if (i == 1) {
      daymet_data <- daymet_load
      time_dictionary <- time_dict
      yr_list <- list(yr)
      dm_var_list <- list(dm_var)
    } else {
      daymet_data <- c(daymet_data, daymet_load)
      time_dictionary <- rbind(time_dictionary, time_dict)
      yr_list[[length(yr_list) + 1]] <- yr
      dm_var_list[[length(dm_var_list) + 1]] <- dm_var
    }
  }
  time_dictionary <- time_dictionary %>%
    arrange(number, year) %>%
    distinct()
  time_dictionary <- as.data.table(time_dictionary)
  # Extracting the years of the Daymet data that was loaded in
  years_loaded <- unique(yr_list)
  years_loaded <- as.numeric(years_loaded)
  # Extracting the Daymet variables of the Daymet data that was loaded in
  dm_var_list <- unique(dm_var_list)
  daymet_variables <- unlist(dm_var_list)
  # Returning a list of objects needed later
  out <- list("time_dictionary" = time_dictionary, "daymet_data" = daymet_data, "years_loaded" = years_loaded, "daymet_variables" = daymet_variables)
  return(out)
}

# Creating function to process the input data
process_data <- function(.input_data = input_data, .years_loaded = years_loaded) {
  # Filtering out any rows in the input data where the date is not within the years of loaded Daymet data
  .input_data <- .input_data %>%
    filter(year(date) %in% .years_loaded)
  # Throwing an error if no observations are remaining
  if (nrow(.input_data) == 0) {
    stop(call. = FALSE, 'Zero observations where the user-supplied event dates are within the years of loaded Daymet data.')
  }
  # Separating the row_index, input coordinates, and dates out into their own dataset
  addresses <- .input_data %>%
    select(row_index, lat, lon, date)
  # Separating the row_index and any other columns out into their own dataset
  extra_columns <- .input_data %>%
    select(-c(lat, lon, date)) %>%
    distinct()
  extra_columns <- as.data.table(extra_columns)
  # Converting the input coordinates to a SpatVector with the Daymet projection
  coords <- vect(addresses, geom = c("lon", "lat"), crs = "+proj=lcc +lat_1=25 +lat_2=60 +lat_0=42.5 +lon_0=-100 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")
  # Returning a list of objects needed later
  out <- list("addresses" = addresses, "extra_columns" = extra_columns, "coords" = coords)
  return(out)
}

# Importing the input data
import_data_out <- import_data()
input_data <- import_data_out$input_data
years <- import_data_out$years
rm(import_data_out)

# Downloading the Daymet NetCDF data
suppressWarnings(daymet_download())
rm(years)
message("Daymet data download completed.")

# Loading the Daymet NetCDF data
daymet_load_out <- daymet_load()
time_dictionary <- daymet_load_out$time_dictionary
daymet_data <- daymet_load_out$daymet_data
years_loaded <- daymet_load_out$years_loaded
daymet_variables <- daymet_load_out$daymet_variables
rm(daymet_load_out)
message(paste0("Daymet NetCDF data loaded for year(s): ", paste(years_loaded, collapse = " "), ", and variable(s): ", paste(daymet_variables, collapse = " "), "."))

# Processing the input data
process_data_out <- process_data()
addresses <- process_data_out$addresses
extra_columns <- process_data_out$extra_columns
coords <- process_data_out$coords
rm(process_data_out, input_data, years_loaded)
message(paste0("Input file ", opt$filename, " imported and processed."))

message("Linking input file to loaded Daymet data...")

# Finding the four nearest Daymet raster cell numbers and their weights that match the input file coordinates
# This helps robustly handle coordinates that fall on or near the border of raster cells
# Weights are assigned based on the inverse distance between a coordinate and the center of a raster cell
cells_weights <- as.data.frame(cells(daymet_data, coords, method = "bilinear"))
cells_weights <- cells_weights %>%
  mutate(row_index = addresses$row_index) %>%
  select(-ID) %>%
  distinct()
cells_weights_long <- cells_weights %>%
  pivot_longer(cols = !row_index, names_to = c(".value", "num"), names_pattern = "(c|w)(1|2|3|4)")
cells_weights_long <- cells_weights_long %>%
  rename(cell = c, weight = w) %>%
  select(-num) %>%
  arrange(row_index)
rm(cells_weights, coords)
addresses <- addresses %>%
  group_by(row_index) %>%
  mutate(row_index_count = row_number()) %>%
  ungroup()
for (i in min(addresses$row_index_count):max(addresses$row_index_count)) {
  cells_weights_long <- cells_weights_long %>%
    mutate(row_index_count = i)
  assign(paste0("addresses_cells_", i), inner_join(addresses, cells_weights_long, by = c("row_index", "row_index_count")))
}
rm(addresses, cells_weights_long)
addresses_cells_list <- mget(ls(pattern = "addresses_cells_"))
addresses <- rbindlist(addresses_cells_list)
rm(list = ls(pattern = "addresses_cells_"))
addresses <- addresses %>%
  select(-row_index_count) %>%
  arrange(row_index, date)

# Removing any input file observations where the Daymet cell raster number is missing
addresses <- addresses %>%
  filter(!is.na(cell)) %>%
  select(-c(lat, lon))
addresses <- as.data.table(addresses)

# Throwing an error if no observations are remaining
if (nrow(addresses) == 0) {
  stop(call. = FALSE, 'Zero observations where the input file coordinates fell within Daymet raster cells.')
}

# Taking care of leap years, per Daymet conventions (12/31 is switched to 12/30)
addresses$date <- if_else(leap_year(addresses$date) & month(addresses$date) == 12 & day(addresses$date) == 31,
                          addresses$date - 1,
                          addresses$date)

# Converting the Daymet SpatRaster raster stack to a data table, with cell numbers
daymet_data_dt <- as.data.frame(daymet_data, cells = TRUE)
daymet_data_dt <- as.data.table(daymet_data_dt)
rm(daymet_data)

# Subsetting the Daymet data table to only the cell numbers that matched the input file coordinates
addresses_cells <- unique(addresses$cell)
daymet_data_dt <- setDT(daymet_data_dt, key = 'cell')[J(addresses_cells)]
rm(addresses_cells)

# Transposing the Daymet data table, one Daymet variable at a time
transpose_daymet <- function(.daymet_data_dt = daymet_data_dt, dm_var) {
  daymet_data_dt_var <- .daymet_data_dt %>%
    select(c("cell", starts_with(dm_var)))
  daymet_data_dt_var <- melt(daymet_data_dt_var, id.vars = "cell", variable.name = "number_year", value.name = dm_var)
  daymet_data_dt_var <- daymet_data_dt_var %>%
    mutate(number_year = str_remove_all(number_year, paste0(dm_var, "_")))
  return(daymet_data_dt_var)
}
for (i in 1:length(daymet_variables)) {
  if (i == 1) {
    daymet_data_long <- transpose_daymet(dm_var = daymet_variables[i])
  }
  else {
    daymet_data_long <- daymet_data_long[transpose_daymet(dm_var = daymet_variables[i]), on = c(cell = "cell", number_year = "number_year")]
  }
}
rm(daymet_data_dt)

# Splitting out number_year in daymet_data_long
daymet_data_long <- daymet_data_long %>%
  separate_wider_delim(number_year, delim = "_", names = c("number", "year"), cols_remove = TRUE)

# Matching the Daymet day numbers to the dates they correspond to
daymet_data_long <- daymet_data_long %>%
  mutate(number = as.integer(number),
         year = as.integer(year))
daymet_data_long <- as.data.table(daymet_data_long)
time_dictionary <- time_dictionary[, number := as.integer(number)]
time_dictionary <- time_dictionary[, year := as.integer(year)]
daymet_data_long <- daymet_data_long[time_dictionary, on = c(number = "number", year = "year")]
daymet_data_long <- daymet_data_long[, c("number", "year") := NULL]
rm(time_dictionary)

# Linking the Daymet data cells to the input file coordinate cells across all dates
main_dataset <- daymet_data_long[addresses, on = c(cell = "cell", date = "date")]
main_dataset <- main_dataset[, "cell" := NULL]
setcolorder(main_dataset, c("row_index", "date"))
rm(daymet_data_long, addresses)

# Removing duplicates (duplicates could have resulted from leap years)
main_dataset <- main_dataset %>%
  distinct()

# Calculating the weighted average of the Daymet variables (from the four nearest Daymet raster cells) per row_index and date
main_dataset <- main_dataset %>%
  mutate(across(where(is.numeric) & matches(daymet_variables), ~ . * weight))
main_dataset <- main_dataset %>%
  group_by(row_index, date) %>%
  mutate(across(where(is.numeric) & matches(daymet_variables), ~ sum(.))) %>%
  mutate(weight = sum(weight)) %>%
  mutate(across(where(is.numeric) & matches(daymet_variables), ~ . / weight)) %>%
  ungroup()
main_dataset <- main_dataset %>%
  select(-weight) %>%
  distinct()
main_dataset <- as.data.table(main_dataset)

# Rounding the Daymet variables to two decimal places
main_dataset <- main_dataset %>%
  mutate(across(where(is.numeric) & matches(daymet_variables), ~ round(., 2)))
rm(daymet_variables)

# Merging in the extra columns
main_dataset <- extra_columns[main_dataset, on = c(row_index = "row_index")]
main_dataset <- main_dataset[, "row_index" := NULL]
rm(extra_columns)

# Removing any rows with all NA
main_dataset <- main_dataset %>%
  filter(!if_all(everything(), is.na))

# Sorting and de-duplicating the final results (duplicates could have resulted from repeat dates)
main_dataset <- main_dataset %>%
  mutate(sort1 = factor(id, ordered = TRUE, levels = unique(mixedsort(id))),
         sort2 = factor(date, ordered = TRUE, levels = unique(mixedsort(date)))) %>%
  arrange(sort1, sort2) %>%
  select(-c(sort1, sort2)) %>%
  distinct()

# Writing the results out as a CSV file
csv_out <- paste0(unlist(str_split(opt$filename, "\\.csv"))[1], "_daymet", ".csv")
fwrite(main_dataset, csv_out, na = "", row.names = FALSE)
message(paste0("Output file ", csv_out, " with linked Daymet data exported to working directory."))

# Optionally deleting the Daymet data that was downloaded from disk
if (opt$delete_daymet) {
  unlink("Daymet_Data", recursive = TRUE, force = TRUE)
  message("Deleted Daymet_Data folder.")
}

# Clearing R environment
rm(list = ls(all.names = TRUE))
message("Daymet DeGAUSS tool processing completed.")
#!/usr/local/bin/Rscript

# Greeting users
dht::greeting()

# Loading libraries without messages or warnings
withr::with_message_sink("/dev/null", library(tidyverse))
withr::with_message_sink("/dev/null", library(terra))
withr::with_message_sink("/dev/null", library(gtools))
withr::with_message_sink("/dev/null", library(data.table))
withr::with_message_sink("/dev/null", library(dht))

doc <- '
      Usage:
      entrypoint.R <filename> [--delete_daymet]
      entrypoint.R (-h | --help)

      Options:
      -h --help  Show this screen
      filename  Name of CSV file
      --delete_daymet  Delete downloaded Daymet data
      '
opt <- docopt::docopt(doc)

# Writing functions
# Creating function to load the pre-downloaded Daymet NetCDF data
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
    daymet_load <- rast(paste0(daymet_file_list[i], "/", netcdf))
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
  years <- unique(yr_list)
  years <- as.numeric(years)
  # Extracting the Daymet variables of the Daymet data that was loaded in
  dm_var_list <- unique(dm_var_list)
  daymet_variables <- unlist(dm_var_list)
  # Extracting the minimum and maximum longitude and latitude of the Daymet data that was loaded in
  min_lon <- unname(ext(daymet_data)[1])
  max_lon <- unname(ext(daymet_data)[2])
  min_lat <- unname(ext(daymet_data)[3])
  max_lat <- unname(ext(daymet_data)[4])
  # Returning a list of objects needed later
  out <- list("time_dictionary" = time_dictionary, "daymet_data" = daymet_data, "years" = years, "daymet_variables" = daymet_variables, "min_lon" = min_lon, "max_lon" = max_lon, "min_lat" = min_lat, "max_lat" = max_lat)
  return(out)
}

# Creating function to import and process the input data
import_data <- function(.csv_filename = opt$filename, .min_lon = min_lon, .max_lon = max_lon, .min_lat = min_lat, .max_lat = max_lat, .years = years) {
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
  # Removing observations where the address is outside of the bounding box of downloaded Daymet data
  input_data <- input_data %>%
    filter(lat >= .min_lat & lat <= .max_lat & lon >= .min_lon & lon <= .max_lon)
  # Throwing an error if no observations are remaining
  if (nrow(input_data) == 0) {
    stop(call. = FALSE, 'Zero observations where the lat and lon coordinates are within the bounding box of downloaded Daymet data.')
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
    select(-start_date, -end_date)
  # Filtering out any rows in the input data where the date is not within the years of downloaded Daymet data
  input_data <- input_data %>%
    filter(year(date) %in% .years)
  # Throwing an error if no observations are remaining
  if (nrow(input_data) == 0) {
    stop(call. = FALSE, 'Zero observations where the user-supplied event dates are within the years of downloaded Daymet data.')
  }
  # Removing any columns in the input data where everything is NA
  input_data <- input_data %>%
    select_if(~ !all(is.na(.))) 
  # Separating the row_index, address coordinates, and dates out into their own dataset
  addresses <- input_data %>%
    select(row_index, lat, lon, date)
  # Separating the row_index and any other columns out into their own dataset
  extra_columns <- input_data %>%
    select(-lat, -lon, -date) %>%
    distinct()
  extra_columns <- as.data.table(extra_columns)
  # Converting the input addresses to a SpatVector with the Daymet projection
  coords <- vect(addresses, geom = c("lon", "lat"), crs = "+proj=lcc +lat_1=25 +lat_2=60 +lat_0=42.5 +lon_0=-100 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")
  # Returning a list of objects needed later
  out <- list("addresses" = addresses, "extra_columns" = extra_columns, "coords" = coords)
  return(out)
}

# Loading the Daymet NetCDF data
daymet_load_out <- daymet_load()
time_dictionary <- daymet_load_out$time_dictionary
daymet_data <- daymet_load_out$daymet_data
years <- daymet_load_out$years
daymet_variables <- daymet_load_out$daymet_variables
min_lon <- daymet_load_out$min_lon
max_lon <- daymet_load_out$max_lon
min_lat <- daymet_load_out$min_lat
max_lat <- daymet_load_out$max_lat
rm(daymet_load_out)

# Importing and processing the input data
import_data_out <- import_data()
addresses <- import_data_out$addresses
extra_columns <- import_data_out$extra_columns
coords <- import_data_out$coords
rm(import_data_out)

# Finding the four nearest Daymet raster cell numbers and their weights that match the input address coordinates
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

# Removing any input address observations where the Daymet cell raster number is missing
addresses <- addresses %>%
  filter(!is.na(cell)) %>%
  select(-c(lat, lon))
addresses <- as.data.table(addresses)

# Throwing an error if no observations are remaining
if (nrow(addresses) == 0) {
  stop(call. = FALSE, 'Zero observations where the input address coordinates fell within Daymet raster cells.')
}

# Taking care of leap years, per Daymet conventions (12/31 is switched to 12/30)
addresses$date <- if_else(leap_year(addresses$date) & month(addresses$date) == 12 & day(addresses$date) == 31,
                          addresses$date - 1,
                          addresses$date)

# Converting the Daymet SpatRaster raster stack to a data table, with cell numbers
daymet_data_dt <- as.data.frame(daymet_data, cells = TRUE)
daymet_data_dt <- as.data.table(daymet_data_dt)
rm(daymet_data)

# Subsetting the Daymet data table to only the cell numbers that matched the input address coordinates
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

# Linking the Daymet data cells to the input address coordinate cells across all dates
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

# Removing any rows with NA
main_dataset <- main_dataset %>%
  na.omit()

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

# Optionally deleting the Daymet data that was downloaded from disk
if (opt$delete_daymet) {
  unlink("Daymet_Data", recursive = TRUE, force = TRUE)
}

# Clearing R environment
rm(list = ls(all.names = TRUE))
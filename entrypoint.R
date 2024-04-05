#!/usr/local/bin/Rscript

# Greeting users

dht::greeting()

## load libraries without messages or warnings

withr::with_message_sink("/dev/null", library(daymetr))
withr::with_message_sink("/dev/null", library(tidyverse))
withr::with_message_sink("/dev/null", library(terra))
withr::with_message_sink("/dev/null", library(gtools))
withr::with_message_sink("/dev/null", library(data.table))
withr::with_message_sink("/dev/null", library(dht))

doc <- '
      Usage:
      entrypoint.R <filename>
      entrypoint.R (-h | --help)

      Options:
      -h --help   Show this screen
      filename  name of csv file
      '
opt <- docopt::docopt(doc)

# Writing functions
# Creating function to import and process the input data
import_data <- function(.csv_filename = opt$filename, .min_lon = min_lon, .max_lon = max_lon, .min_lat = min_lat, .max_lat = max_lat, .year_start = year_start, .year_end = year_end) {
  # Checking that the input data is a CSV file
  if (!str_detect(.csv_filename, ".csv$")) {
    stop(call. = FALSE, 'Input file must be a CSV.')
  }
  # Reading in the input data
  input_data <- fread(.csv_filename, header = TRUE, sep = ",")
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
  # Removing observations where the address is outside of the bounding box of Daymet data
  input_data <- input_data %>%
    filter(lat >= .min_lat & lat <= .max_lat & lon >= .min_lon & lon <= .max_lon)
  # Throwing an error if no observations are remaining
  if (nrow(input_data) == 0) {
    stop(call. = FALSE, 'Zero observations where the lat and lon coordinates are within the bounding box of Daymet data.')
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
  # Filtering out any rows in the input data where the date is before the first year of downloaded Daymet data
  input_data <- input_data %>%
    filter(!(year(date) < .year_start))
  # Throwing an error if no observations are remaining
  if (nrow(input_data) == 0) {
    stop(call. = FALSE, 'Zero observations where the start_date is within or after the first year of downloaded Daymet data.')
  }  
  # Filtering out any rows in the input data where the date is after the last year of downloaded Daymet data
  input_data <- input_data %>%
    filter(!(year(date) > .year_end))
  # Throwing an error if no observations are remaining
  if (nrow(input_data) == 0) {
    stop(call. = FALSE, 'Zero observations where the end_date is within or before the last year of downloaded Daymet data.')
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
  # Converting the input addresses to a SpatVector
  coords <- vect(addresses, geom = c("lon", "lat"), crs = "+proj=longlat +ellips=WGS84")
  # Returning a list of objects needed later
  out <- list("addresses" = addresses, "extra_columns" = extra_columns, "coords" = coords)
  return(out)
}

# Creating function to load the Daymet NetCDF data
daymet_load <- function() {
  # Loading the NetCDF files downloaded from Daymet as a SpatRaster raster stack
  netcdf_list <- list.files(path = "app", pattern = "_ncss.nc$")
  # Initializing a time dictionary
  time_dict <- tibble(number = 1:365)
  for (i in 1:length(netcdf_list)) {
    # Extracting the year and Daymet variable from the file to be loaded in
    yr <- str_extract(netcdf_list[i], "[0-9]{4}")
    dm_var <- unlist(str_split(netcdf_list[i], "_"))[1]
    # Creating a vector of layer names
    layer_names <- as.character(1:365)
    layer_names <- paste0(dm_var, "_", layer_names, "_", yr)
    # Loading the Daymet data
    daymet_load <- rast(netcdf_list[i])
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
  # Extracting the year start and year end of the Daymet data that was loaded in
  yr_list <- unique(yr_list)
  year_start <- as.numeric(min(unlist(yr_list)))
  year_end <- as.numeric(max(unlist(yr_list)))
  # Extracting the Daymet variables of the Daymet data that was loaded in
  dm_var_list <- unique(dm_var_list)
  daymet_variables <- paste(unlist(dm_var_list), collapse = ",")
  # Extracting the minimum and maximum longitude and latitude of the Daymet data that was loaded in
  proj_daymet_data <- project(daymet_data, "+proj=longlat +ellips=WGS84")
  min_lon <- unname(ext(proj_daymet_data)[1])
  max_lon <- unname(ext(proj_daymet_data)[2])
  min_lat <- unname(ext(proj_daymet_data)[3])
  max_lat <- unname(ext(proj_daymet_data)[4])
  # Returning a list of objects needed later
  out <- list("time_dictionary" = time_dictionary, "daymet_data" = daymet_data, "year_start" = year_start, "year_end" = year_end, "daymet_variables" = daymet_variables, "min_lon" = min_lon, "max_lon" = max_lon, "min_lat" = min_lat, "max_lat" = max_lat)
  return(out)
}

# Loading the Daymet NetCDF data
daymet_load_out <- daymet_load()
time_dictionary <- daymet_load_out$time_dictionary
daymet_data <- daymet_load_out$daymet_data
year_start <- daymet_load_out$year_start
year_end <- daymet_load_out$year_end
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

# Changing the coordinate reference system of the input addresses so they match that of Daymet
new_crs <- crs(daymet_data, proj = TRUE)
proj_coords <- project(coords, new_crs)
rm(coords)

# Finding the Daymet raster cell numbers that match the input address coordinates
addresses <- addresses %>%
  mutate(cell = unname(cells(daymet_data, proj_coords)[, "cell"]))
rm(proj_coords)

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

# Transposing the Daymet data table, one Daymet variable at a time
transpose_daymet <- function(.daymet_data_dt = daymet_data_dt, dm_var) {
  daymet_data_dt_var <- .daymet_data_dt %>%
    select(c("cell", starts_with(dm_var)))
  daymet_data_dt_var <- melt(daymet_data_dt_var, id.vars = "cell", variable.name = "number_year", value.name = dm_var)
  daymet_data_dt_var <- daymet_data_dt_var %>%
    mutate(number_year = str_remove_all(number_year, paste0(dm_var, "_")))
  return(daymet_data_dt_var)
}
daymet_variables <- str_remove_all(daymet_variables, " ")
daymet_variables <- str_split(daymet_variables, ",", simplify = TRUE)
for (i in 1:length(daymet_variables)) {
  if (i == 1) {
    daymet_data_long <- transpose_daymet(dm_var = daymet_variables[i])
  }
  else {
    daymet_data_long <- daymet_data_long[transpose_daymet(dm_var = daymet_variables[i]), on = c(cell = "cell", number_year = "number_year")]
  }
}
rm(daymet_data_dt)

# Rounding the Daymet variables to two decimal places
daymet_data_long <- daymet_data_long %>%
  mutate(across(where(is.numeric) & matches(daymet_variables), ~ round(., 2)))
rm(daymet_variables)

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

# Merging in the extra columns
main_dataset <- extra_columns[main_dataset, on = c(row_index = "row_index")]
main_dataset <- main_dataset[, "row_index" := NULL]
rm(extra_columns)

# Removing any rows with NA
main_dataset <- main_dataset %>%
  na.omit()

# Sorting and de-duplicating the final results (duplicates could have resulted from leap years or repeat dates)
main_dataset <- main_dataset %>%
  mutate(sort1 = factor(id, ordered = TRUE, levels = unique(mixedsort(id))),
         sort2 = factor(date, ordered = TRUE, levels = unique(mixedsort(date)))) %>%
  arrange(sort1, sort2) %>%
  select(-c(sort1, sort2)) %>%
  distinct()

# Writing the results out as a CSV file
csv_out <- paste0(unlist(str_split(opt$filename, ".csv"))[1], "_daymet", ".csv")
fwrite(main_dataset, csv_out, na = "", row.names = FALSE)
rm(list = ls(all.names = TRUE))

# [Optional - Uncomment to run] Deleting the NetCDF files from disk
#unlink(list.files(pattern = "_ncss.nc$"), force = TRUE)
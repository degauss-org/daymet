# daymet <a href='https://degauss.org'><img src='https://github.com/degauss-org/degauss_hex_logo/raw/main/PNG/degauss_hex.png' align='right' height='138.5' /></a>

[![](https://img.shields.io/github/v/release/degauss-org/daymet?color=469FC2&label=version&sort=semver)](https://github.com/degauss-org/daymet/releases)
[![container build status](https://github.com/degauss-org/daymet/workflows/build-deploy-release/badge.svg)](https://github.com/degauss-org/daymet/actions/workflows/build-deploy-release.yaml)

## Background

Daymet weather variables include daily day length, precipitation, shortwave radiation, snow water equivalent, maximum and minimum temperature, and vapor pressure produced on a 1 km x 1 km gridded surface over continental North America and Hawaii from 1980 and over Puerto Rico from 1950 through the end of the most recent full calendar year.

Daymet data documentation: https://daac.ornl.gov/DAYMET/guides/Daymet_Daily_V4.html and https://www.earthdata.nasa.gov/data/projects/daymet.

Note: The Daymet calendar is based on a standard calendar year. All Daymet years, including leap years, have 1–365 days. For leap years, the Daymet data include leap day (February 29) and December 31 is discarded from leap years to maintain a 365-day year.

## Pre-Downloading Daymet Data

Before linking Daymet weather variables to a file of dates and coordinates (e.g., `my_addresses.csv` - see below), the Daymet data must first be pre-downloaded. The R file `appeears_daymet.R` is a helper program so that you may accomplish this task, which downloads Daymet data via the [NASA EarthData AppEEARS API](https://appeears.earthdatacloud.nasa.gov/).

Prior to downloading the Daymet data, you will need to create a [NASA EarthData account](https://urs.earthdata.nasa.gov/), if you don't yet have one. Be sure to note your NASA EarthData username and password. Upon first use of `appeears_daymet.R` you will need to enter both your NASA EarthData username and password. Subsequent uses of `appeears_daymet.R` will just require you to enter your NASA EarthData password.

Instructions for use of `appeears_daymet.R` are included in a header in the file, and are summarized here. Be sure that when running `appeears_daymet.R`, you are doing so within the same working directory as your file of dates and coordinates (e.g., `my_addresses.csv` - see below). Within `appeears_daymet.R`, you can specify the Daymet weather variable(s), year(s), and bounding box of Daymet data to download.

Daymet weather variable(s) may be any combination of:

- **`dayl`**: day length
- **`prcp`**: precipitation
- **`srad`**: shortwave radiation
- **`swe`**: snow water equivalent
- **`tmax`**: maximum temperature
- **`tmin`**: minimum temperature
- **`vp`**: vapor pressure

An example of specifying all Daymet weather variables within `appeears_daymet.R` is:

```sh
layers <- c("dayl", "prcp", "srad", "swe", "tmax", "tmin", "vp")
```

Be sure that the assigned object name remains as `layers` and that the Daymet weather variables of interest are entered as a comma-separated list, with quotes around the variable names. If the input for Daymet weather variables includes an invalid variable name, then `appeears_daymet.R` will default to downloading all Daymet weather variables.

Year(s) of Daymet data needed may be any year(s) from 1980 to the most recent full calendar year for geographic regions over continental North America or Hawaii, and from 1950 to the most recent full calendar year for geographic regions over Puerto Rico.

An example of specifying Daymet data for 1980 and 2024 within `appeears_daymet.R` is:

```sh
years <- c(1980, 2024)
```

Be sure that the assigned object name remains as `years` and that the Daymet year(s) of interest are entered as a comma-separated list of numeric four-digit year(s).

Bounding box of Daymet data to download must be maximum and minimum latitude and longitude coordinates as numeric decimal degrees.

An example of specifying a Daymet data bounding box over Cook County, IL within `appeears_daymet.R` is:

```sh
maximum_latitude <- 42.154247
minimum_latitude <- 41.470117
maximum_longitude <- -87.525706
minimum_longitude <- -88.263390
```

Be sure that the assigned object names remain as `maximum_latitude`, `minimum_latitude`, `maximum_longitude`, and `minimum_longitude` and that the minimum latitude and longitude are less than the maximum latitude and longitude. If the bounding box of Daymet data to download is specified to be very large, then this will result in large download sizes and may lead to memory issues within the Daymet DeGAUSS tool. If you have a wide spread of coordinates that you want to link to Daymet weather variables, then it may be best to stratify your Daymet data download and linkage into separate geographic regions.

When run, `appeears_daymet.R` will store the downloaded Daymet data within a folder named `Daymet_Data` within the current working directory.

## Using the Daymet DeGAUSS Tool

With `Daymet_Data` in the current working directory, if `my_addresses.csv` is a file in the current working directory with ID column `id`, start and end date columns `start_date` and `end_date`, and coordinate columns `lat` and `lon`, then the [DeGAUSS command](https://degauss.org/using_degauss.html#DeGAUSS_Commands):

```sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/daymet:1.0.0 my_addresses.csv
```

will produce `my_addresses_daymet.csv` with columns added for the pre-downloaded Daymet data weather variables (any of `dayl`, `prcp`, `srad`, `swe`, `tmax`, `tmin`, `vp`), linked by date and coordinate. Other columns may be present in the input `my_addresses.csv` file, and these other columns will be linked in and included in the output `my_addresses_daymet.csv` file.

### Optional Argument

- **`delete_daymet`**: Flag to delete the pre-downloaded Daymet data within the `Daymet_Data` folder after it has been linked. Default is to not delete the Daymet data.

An example DeGAUSS command with this optional argument would be:

```sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/daymet:1.0.0 my_addresses.csv --delete_daymet
```

which will link the pre-downloaded Daymet data, output a `my_addresses_daymet.csv` file, and then delete the `Daymet_Data` folder and all files within it.

## Geomarker Methods

Daymet data on a specified date is linked to coordinate data within the `my_addresses.csv` file by matching on the four nearest Daymet 1 km x 1 km raster cell numbers (per coordinate). The Daymet weather variable values within these four nearest raster cells are assigned weights, based on the inverse distance between a coordinate and the center of a raster cell. A weighted average of the Daymet weather variable values within these four nearest raster cells is then calculated to provide the final Daymet weather variable estimate, which is returned to the user. This method helps to robustly handle input coordinates that fall on or near the border of Daymet raster cells.

## Geomarker Data

- Weather data are downloaded from [Daymet](https://www.earthdata.nasa.gov/data/projects/daymet) as NetCDF file(s) using the [NASA EarthData AppEEARS API](https://appeears.earthdatacloud.nasa.gov/) via the [appeears package](https://bluegreen-labs.github.io/appeears/).
- The R code that links the downloaded Daymet weather data to the input dates and coordinates is within `entrypoint.R`.

## DeGAUSS Details

The Daymet DeGAUSS tool was created by Ben Barrett and Peter Graffy, with contributions from Erika Rasnick Manning, Jake Mackie, and Luke Rasmussen.
For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS homepage](https://degauss.org).
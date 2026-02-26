# daymet <a href='https://degauss.org'><img src='https://github.com/degauss-org/degauss_hex_logo/raw/main/PNG/degauss_hex.png' align='right' height='138.5' /></a>

[![](https://img.shields.io/github/v/release/degauss-org/daymet?color=469FC2&label=version&sort=semver)](https://github.com/degauss-org/daymet/releases)
[![container build status](https://github.com/degauss-org/daymet/workflows/build-deploy-release/badge.svg)](https://github.com/degauss-org/daymet/actions/workflows/build-deploy-release.yaml)

## Background

Daymet weather variables include daily day length, precipitation, shortwave radiation, snow water equivalent, maximum and minimum temperature, and vapor pressure produced on a 1 km x 1 km gridded surface over continental North America and Hawaii from 1980 and over Puerto Rico from 1950 through the end of the most recent full calendar year.

Daymet data documentation: https://daac.ornl.gov/DAYMET/guides/Daymet_Daily_V4.html and https://www.earthdata.nasa.gov/data/projects/daymet.

Note: The Daymet calendar is based on a standard calendar year. All Daymet years, including leap years, have 1–365 days. For leap years, the Daymet data include leap day (February 29) and December 31 is discarded from leap years to maintain a 365-day year.

## Using

Before linking Daymet weather variables to a file of dates and coordinates (e.g., `my_addresses.csv` - see below), you will need to create a [NASA EarthData account](https://urs.earthdata.nasa.gov/), if you don't yet have one. Be sure to note your NASA EarthData username and password, as you will need these when calling the Daymet DeGAUSS tool.

If `my_addresses.csv` is a file in the current working directory with ID column `id`, start and end date columns `start_date` and `end_date`, and coordinate columns `lat` and `lon`, then the [DeGAUSS command](https://degauss.org/using_degauss.html#DeGAUSS_Commands):

```sh
docker run -e USER="my_username" -e PASSWORD="my_password" --rm -v $PWD:/tmp ghcr.io/degauss-org/daymet:1.0.0 my_addresses.csv
```

with `my_username` and `my_password` being your NASA EarthData username and password, will produce `my_addresses_daymet.csv` with added columns:

- **`dayl`**: day length
- **`prcp`**: precipitation
- **`srad`**: shortwave radiation
- **`swe`**: snow water equivalent
- **`tmax`**: maximum temperature
- **`tmin`**: minimum temperature
- **`vp`**: vapor pressure

linked by date and coordinate. All downloaded Daymet data will be stored within a folder named `Daymet_Data` within the current working directory.

Other columns may be present in the input `my_addresses.csv` file, and these other columns will be linked in and included in the output `my_addresses_daymet.csv` file.

### Optional Arguments

- **`vars`**: Comma-separated string of Daymet weather variable(s): Any combination of "dayl,prcp,srad,swe,tmax,tmin,vp" (quotes are optional). Default is to download and link all Daymet weather variables.
- **`min_lat`**: Minimum latitude (in numeric decimal degrees) for bounding box of Daymet data to download. Default is to infer bounding box from input file coordinates.
- **`max_lat`**: Maximum latitude (in numeric decimal degrees) for bounding box of Daymet data to download. Default is to infer bounding box from input file coordinates.
- **`min_lon`**: Minimum longitude (in numeric decimal degrees) for bounding box of Daymet data to download. Default is to infer bounding box from input file coordinates.
- **`max_lon`**: Maximum longitude (in numeric decimal degrees) for bounding box of Daymet data to download. Default is to infer bounding box from input file coordinates.
- **`delete_daymet`**: Flag to delete the downloaded Daymet data within the `Daymet_Data` folder after it has been linked. Default is to not delete the Daymet data.

An example DeGAUSS command with all optional arguments used would be:

```sh
docker run -e USER="my_username" -e PASSWORD="my_password" --rm -v $PWD:/tmp ghcr.io/degauss-org/daymet:1.0.0 my_addresses.csv --vars=tmax,vp,prcp --min_lat=41.470117 --max_lat=42.154247 --min_lon=-88.263390 --max_lon=-87.525706 --delete_daymet
```

which will return an output `my_addresses_daymet.csv` file containing maximum temperature, vapor pressure, and precipitation for observations within a bounding box over Cook County, IL, and then delete the `Daymet_Data` folder and all files within it.

## Geomarker Methods

Daymet data on a specified date is linked to coordinate data within the `my_addresses.csv` file by matching on the four nearest Daymet 1 km x 1 km raster cell numbers (per coordinate). The Daymet weather variable values within these four nearest raster cells are assigned weights, based on the inverse distance between a coordinate and the center of a raster cell. A weighted average of the Daymet weather variable values within these four nearest raster cells is then calculated to provide the final Daymet weather variable estimate, which is returned to the user. This method helps to robustly handle input coordinates that fall on or near the border of Daymet raster cells.

If the bounding box coordinates for Daymet data download are not supplied in the optional arguments, they will be inferred from the `my_addresses.csv` file with a randomly added 0.5-1.0 decimal degree buffer to the minimum/maximum latitude and longitude to enhance data privacy.

## Geomarker Data

- Weather data are downloaded from [Daymet](https://www.earthdata.nasa.gov/data/projects/daymet) as NetCDF file(s) using the [NASA EarthData AppEEARS API](https://appeears.earthdatacloud.nasa.gov/) via the [appeears package](https://bluegreen-labs.github.io/appeears/).
- The R code that links the Daymet weather data to the input dates and coordinates is within `entrypoint.R`.

## Warning

If the bounding box of Daymet data to download is inferred from input file coordinates, then this may result in large download sizes and lead to memory issues within the Daymet DeGAUSS tool if the input file coordinates are very spread out. If you have a wide spread of coordinates that you want to link to Daymet weather variables, then it may be best to stratify your input dataset to coordinates within separate geographic regions.

## DeGAUSS Details

The Daymet DeGAUSS tool was created by Ben Barrett and Peter Graffy, with contributions from Erika Rasnick Manning, Jake Mackie, and Luke Rasmussen.
For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS homepage](https://degauss.org).
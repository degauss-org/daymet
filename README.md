# daymet <a href='https://degauss.org'><img src='https://github.com/degauss-org/degauss_hex_logo/raw/main/PNG/degauss_hex.png' align='right' height='138.5' /></a>

[![](https://img.shields.io/github/v/release/degauss-org/daymet?color=469FC2&label=version&sort=semver)](https://github.com/degauss-org/daymet/releases)
[![container build status](https://github.com/degauss-org/daymet/workflows/build-deploy-release/badge.svg)](https://github.com/degauss-org/daymet/actions/workflows/build-deploy-release.yaml)

## Background

Daymet weather variables include daily minimum and maximum temperature, precipitation, vapor pressure, shortwave radiation, snow water equivalent, and day length produced on a 1 km x 1 km gridded surface over continental North America and Hawaii from 1980 and over Puerto Rico from 1950 through the end of the most recent full calendar year.

Daymet data documentation: https://daac.ornl.gov/DAYMET/guides/Daymet_Daily_V4.html

Note: The Daymet calendar is based on a standard calendar year. All Daymet years, including leap years, have 1–365 days. For leap years, the Daymet data include leap day (February 29) and December 31 is discarded from leap years to maintain a 365-day year.

## Using

If `my_addresses.csv` is a file in the current working directory with ID column `id`, start and end date columns `start_date` and `end_date`, and coordinate columns named `lat` and `lon`, then the [DeGAUSS command](https://degauss.org/using_degauss.html#DeGAUSS_Commands):

```sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/daymet:0.1.0 my_addresses.csv
```

will produce `my_addresses_daymet_0.1.0.csv` with added columns:

- **`tmax`**: maximum temperature
- **`tmin`**: minimum temperature
- **`srad`**: shortwave radiation
- **`vp`**: vapor pressure
- **`swe`**: snow water equivalent
- **`prcp`**: precipitation
- **`dayl`**: day length

Other columns may be present in the input `my_addresses.csv` file, and these other columns will be linked in and included in the output `my_addresses_daymet_0.1.0.csv` file.

### Optional Arguments

- **`vars`**: Comma-separated string of Daymet variables: Any combination of "tmax,tmin,srad,vp,swe,prcp,dayl" (quotes are optional). Default is to download and link all Daymet variables.
- **`min_lon`**: Minimum longitude (in decimal degrees) of bounding box for Daymet data download. Default is to infer bounding box from address coordinates.
- **`max_lon`**: Maximum longitude (in decimal degrees) of bounding box for Daymet data download. Default is to infer bounding box from address coordinates.
- **`min_lat`**: Minimum latitude (in decimal degrees) of bounding box for Daymet data download. Default is to infer bounding box from address coordinates.
- **`max_lat`**: Maximum latitude (in decimal degrees) of bounding box for Daymet data download. Default is to infer bounding box from address coordinates.
- **`region`**: Daymet spatial region: "na" for continental North America, "hi" for Hawaii, or "pr" for Puerto Rico (quotes are optional). Default is continental North America.

An example DeGAUSS command with all optional arguments used would be:

```sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/daymet:0.1.0 my_addresses.csv tmax,vp,prcp -88.263390 -87.525706 41.470117 42.154247 na
```

which will return maximum temperature, vapor pressure, and precipitation for observations within a bounding box of Cook County, IL. It is important to specify bounding box coordinates in the order of: `min_lon`, `max_lon`, `min_lat`, `max_lat`.

## Geomarker Methods

Daymet data on a specified date is linked to coordinate data within the `my_addresses.csv` file by matching on the Daymet 1 km x 1 km raster cell number.

## Geomarker Data

- Environmental data is downloaded from [Daymet](https://daymet.ornl.gov/) as netCDF file(s) using the [daymetr package](https://github.com/bluegreen-labs/daymetr).
- The R code that links the environmental data to the input coordinates is within `entrypoint.R`.

## Warning

If the bounding box for Daymet data download is inferred from address coordinates, then the size of the Daymet data download may be quite large if the address coordinates are very spread out. If a wide spread of coordinates is desired, then it may be best to stratify your input dataset to coordinates within separate geographic regions.

## DeGAUSS Details

For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS homepage](https://degauss.org).
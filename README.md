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
- **`srad`**: solar radiation
- **`vp`**: vapor pressure
- **`swe`**: snow water equivalent
- **`prcp`**: precipitation
- **`dayl`**: day length

### Optional Argument

- Optional arguments include:
- **`vars`**: [Optional] Comma-separated string of Daymet variables: "tmax,tmin,srad,vp,swe,prcp,dayl". Default is to download and link all Daymet variables.
- **`min_lon`**: [Optional] Minimum longitude (in decimal degrees) of bounding box for Daymet data download. Default is to infer bounding box from address coordinates.
- **`max_lon`**: [Optional] Maximum longitude (in decimal degrees) of bounding box for Daymet data download. Default is to infer bounding box from address coordinates.
- **`min_lat`**: [Optional] Minimum latitude (in decimal degrees) of bounding box for Daymet data download. Default is to infer bounding box from address coordinates.
- **`max_lat`**: [Optional] Maximum latitude (in decimal degrees) of bounding box for Daymet data download. Default is to infer bounding box from address coordinates.
- **`region`**: [Optional] Daymet spatial region ("na" for continental North America, "hi" for Hawaii, or "pr" for Puerto Rico). Default is continental North America.

## Geomarker Methods

- If needed, put details here about the methods and assumptions used in the geomarker assessment process.

## Geomarker Data

- List how geomarker was created, ideally including any scripts within the repo used to do so or linking to an external repository
- If applicable, list where geomarker data is stored in S3 using a hyperlink like: [`s3://path/to/daymet.rds`](https://geomarker.s3.us-east-2.amazonaws.com/path/to/daymet.rds)

## DeGAUSS Details

For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS homepage](https://degauss.org).
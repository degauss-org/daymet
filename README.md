# daymet <a href='https://degauss.org'><img src='https://github.com/degauss-org/degauss_hex_logo/raw/main/PNG/degauss_hex.png' align='right' height='138.5' /></a>

[![](https://img.shields.io/github/v/release/degauss-org/daymet?color=469FC2&label=version&sort=semver)](https://github.com/degauss-org/daymet/releases)
[![container build status](https://github.com/degauss-org/daymet/workflows/build-deploy-release/badge.svg)](https://github.com/degauss-org/daymet/actions/workflows/build-deploy-release.yaml)

## Using

If `my_address_file_geocoded.csv` is a file in the current working directory with coordinate columns named `lat` and `lon`, then the [DeGAUSS command](https://degauss.org/using_degauss.html#DeGAUSS_Commands):

```sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/daymet:0.1.0 my_address_file_geocoded.csv
```

will produce `my_address_file_geocoded_daymet_0.1.0.csv` with added columns:

- **`this_geomarker`**: a definition of this geomarker
- **`that_geomarker`**: a definition of that geomarker

### Optional Argument

- If this DeGAUSS container takes an optional argument, describe its usage and effects here.
- Be sure to also update the example output file name with the argument value.

## Geomarker Methods

- If needed, put details here about the methods and assumptions used in the geomarker assessment process.

## Geomarker Data

- List how geomarker was created, ideally including any scripts within the repo used to do so or linking to an external repository
- If applicable, list where geomarker data is stored in S3 using a hyperlink like: [`s3://path/to/daymet.rds`](https://geomarker.s3.us-east-2.amazonaws.com/path/to/daymet.rds)

## DeGAUSS Details

For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS homepage](https://degauss.org).
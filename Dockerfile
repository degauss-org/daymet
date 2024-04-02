# Load R image
FROM rocker/r-ver:4.3.0

# DeGAUSS container metadata
 ENV degauss_name="daymet"
 ENV degauss_version="0.1.1"
 ENV degauss_description="daymet climate variables"
 ENV degauss_argument="short description of optional argument [default: 'insert_default_value_here']"

# add OCI labels based on environment variables too
 LABEL "org.degauss.name"="${degauss_name}"
 LABEL "org.degauss.version"="${degauss_version}"
 LABEL "org.degauss.description"="${degauss_description}"
 LABEL "org.degauss.argument"="${degauss_argument}"

WORKDIR /app

 RUN apt-get update -y
 RUN apt-get install libxml2-dev zlib1g-dev libfontconfig1-dev libssl-dev libcurl4-openssl-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libudunits2-dev cmake libnetcdf-dev libgdal-dev libgeos-dev libproj-dev libsqlite0-dev -y

# Install R dependencies
 RUN R -e "install.packages(c('daymetr', 'tidyverse', 'terra', 'gtools', 'data.table', 'remotes', 'withr'))"
 RUN R --quiet -e "remotes::install_github('degauss-org/dht')"

COPY entrypoint.R .

WORKDIR /tmp

ENTRYPOINT ["/usr/local/bin/Rscript", "/app/entrypoint.R"]


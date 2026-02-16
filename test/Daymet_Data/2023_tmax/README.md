# AppEEARS Area Sample Extraction Readme  

## Table of Contents  

1. Request Parameters  
2. Request File Listing  
3. Area Sample Extraction Process  
4. Area Sample Naming Convention  
5. Data Quality  
    5.1. Moderate Resolution Imaging Spectroradiometer (MODIS)  
    5.2. NASA MEaSUREs Shuttle Radar Topography Mission (SRTM) Version 3 (v3)  
    5.3. NASA Visible Infrared Imaging Radiometer Suite (VIIRS)  
    5.4. Soil Moisture Active Passive (SMAP)  
    5.5. Daymet (v4R1)
    5.6.1. Ecosystem Spaceborne Thermal Radiometer Experiment on Space Station (ECOSTRESS) Swath V2
    5.6.2. Ecosystem Spaceborne Thermal Radiometer Experiment on Space Station (ECOSTRESS) Tiled V2
    5.7. Advanced Spaceborne Thermal Emission and Reflection Radiometer (ASTER) Global Digital Elevation Model (GDEM) Version 3 (v3) and Global Water Bodies Database (WBD) Version 1 (v1)  
    5.8. NASA MEaSUREs NASA Digital Elevation Model (DEM) Version 1 (v1)  
    5.9. Harmonized Landsat Sentinel-2 (HLS) Version 2.0  
    5.10. Landsat Collection 2 (C2) U.S. Analysis Ready Data (ARD)  
    5.11. US National Park Service (NPS) Historical Water Balance for the Continental United States (CONUS)
    5.12. Earth surface Mineral dust source InvesTigation (EMIT)  L1B Radiance and L2A Reflectance Collections
    5.13. Earth surface Mineral dust source InvesTigation (EMIT)  L2B Estimated Mineral Identification, Band Depth and Uncertainty Collection
6. Data Caveats  
7. Documentation  
8. Sample Request Retention  
9. Data Product Citations  
10. Software Citation  
11. Feedback  

## 1. Request Parameters  

    Name: 2023_tmax  

    Date Completed: 2026-02-13T18:49:52.493350  

    ID: 37d48715-35d7-4f1d-adc7-bcb5222bc511  

    Details:  

        
        Number of Vector Features:    1  

        Start Date:                   01-01-2023  

        End Date:                     12-31-2023  
        
        Layers:  

                tmax (DAYMET.004)  
      
        Output Projection:            Geographic
        Datum:                        WGS84
    
        EPSG:                         4326  
    
        PROJ.4:                       "+proj=longlat +datum=WGS84 +no_defs=True"  
    
        Output Format:                netcdf4  

    Version: This request was processed by AppEEARS version 3.110  

## 2. Request File Listing  

**Supporting Files:**  

- 2023-tmax-DAYMET-004-metadata.xml
- 2023-tmax-granule-list.txt
- 2023-tmax-request.json
- DAYMET-004-Statistics.csv

**Data Files:**  

Number of Extracted Data Files: 1  
Total Size of Extracted Data Files: 3.13 MB  

## 3. Area Sample Extraction Process  

Upon successful submission of an area sample request, AppEEARS initiates a processing pipeline that utilizes various services and utilities to identify and process source granules matching the query parameters. This pipeline can reproject the area(s) of interest and source files to the selected projection and will clips data to the defined area(s). Note that AppEEARS will filters out outputs containing only fill values, ensuring no empty output files are generated.

The PROJ.4 definitions for each data collection available through AppEEARS are listed below.

### MODIS (TERRA, AQUA, & Combined)  

    "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs=True"

### SRTM v3 (30m & 90m)  

    "+proj=longlat +datum=WGS84 +no_defs=True"  

### MODIS Snow Products (TERRA & AQUA)  

    "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs=True"   

### NASA VIIRS  

    "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs=True"  

### SMAP - Global  

    "+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs=True"  

### SMAP - Northern Hemisphere  

    "+proj=laea +lat_0=90 +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs=True"  

### Daymet v4R1

    "+proj=lcc +lat_0=42.5 +lat_1=25 +lat_2=60 +lon_0=-100 +x_0=0 +y_0=0 +ellps=WGS84 +units=km +no_defs=True"  

### ECOSTRESS Swath V1 and V2 (see data caveats section below)  

    "+proj=longlat +datum=WGS84 +no_defs=True"  

### ECOSTRESS Tiled V2  

    "+proj=utm  +zone=XX +ellps=WGS84 +units=m +no_defs=True"

Where "XX" = UTM zone number.  

Example:  

    "+proj=utm  +zone=13 +ellps=WGS84 +units=m +no_defs=True"

### ASTER GDEM v3 and Global Water Bodies Database v1  

    "+proj=longlat +datum=WGS84 +no_defs=True"  

### NASADEM v1 (30m)  

    "+proj=longlat +datum=WGS84 +no_defs=True"  

### HLS v2.0 (HLSL30 v002 and HLSS30 v002)  

    "+proj=utm  +zone=XX +ellps=WGS84 +units=m +no_defs=True"

Where "XX" = UTM zone number.  

Example:  

    "+proj=utm  +zone=13 +ellps=WGS84 +units=m +no_defs=True"  

### Landsat C2 ARD

Landsat C2 ARD has 3 projections, one for the conterminous United States (CONUS), one for Alaska, and one for Hawaii.

CONUS:

    "+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs=True"

Alaska:

    "+proj=aea +lat_0=50 +lon_0=-154 +lat_1=55 +lat_2=65 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs=True"

Hawaii:

    "+proj=aea +lat_0=3 +lon_0=-157 +lat_1=8 +lat_2=18 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs=True"

### US NPS Water Balance

    "+proj=lcc +lat_1=25 +lat_2=60 +lat_0=42.5 +lon_0=-100 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs=True"

### EMIT L1B Radiance and L2A Reflectance

EMIT L1B and L2A products can be requested in spatially raw, non-orthorectified format with an accompanying geometric lookup table, or already orthorectified.

    "+proj=longlat +datum=WGS84 +no_defs=True"

### EMIT L2B Estimated Mineral Identification, Band Depth and Uncertainty

Similarly to other EMIT products, EMIT L2B Mineral products can be requested in spatially raw, non-orthorectified format with an accompanying geometric lookup table, or already orthorectified.

    "+proj=longlat +datum=WGS84 +no_defs=True"

#### Feature Bounding Box Calculation  

- `UpperLeft   =   (maxLat + cellSize), (minLon - cellSize)`  
- `LowerLeft   =   (minLat - cellSize), (minLon - cellSize)`  
- `UpperRight  =   (maxLat + cellSize), (maxLon + cellSize)`  
- `LowerRight  =   (minLat - cellSize), (maxLon + cellSize)`  

For each feature, a series of tools and services are used to determine which spatial tiles intersect with the coordinates of the feature bounding box for the data layer of interest. These tiles are extracted (from OPeNDAP) to a server-side work environment where they are mosaicked into an image. Tile extraction and processing is implemented for each requested composite period (e.g., daily, weekly, 8-day, 16-day, monthly, seasonal, or annual) to create a time series image stack. If the user chooses to have the output projection for each extracted data file match, then the image stack is reprojected into the user-requested projection using the PROJ.4 definition described above. The image stacks are finally clipped to the input feature shape to only maintain the data intersecting the feature shape. Data outside of the feature shape are converted to a product-specific NODATA value. Each clipped image in the time series image stack is saved as a CF-compliant NetCDF file or in a series of Geospatial Tagged Image File Format (GeoTIFF) files with a unique name following the naming conventions described in Section 4 of this README.

AppEEARS implements a strict procedure for reprojecting data outputs. Pixel size and resampling methods are non-customizable in AppEEARS. Reprojected data are produced using the Geospatial Data Abstraction Library (GDAL) gdalwarp function in combination with the PROJ.4 string definition for the user-defined output projection type. Reprojection is performed using nearest neighbor resampling. If the projection units are the same between the native and output projections, the native pixel size is used to reproject the image. If the projection units between the native and output projections are different (e.g. sinusoidal (m) to geographic (degrees), pixel size is calculated by reprojecting the center pixel of the original image, calculating its width and height, and then squaring all pixels). The latitude and longitude of the region of interest are maintained in the conversion.

**NOTE:**  

- Requested date ranges may not match the reference date for multi-day products. AppEEARS takes an inclusive approach when extracting data for sample requests, often returning data that extends beyond the requested date range. This approach ensures that the returned data includes records for the entire requested date range.  
- If selected, the SRTM v3, ASTER GDEM v3 and Global Water Bodies Database v1, and NASADEM v1 products will be extracted regardless of the time period specified in AppEEARS because they are static datasets. The date field in the data tables reflect the nominal date for each of these products.  
- If the visualizations indicate that there are no data to display, proceed to checking the .csv output file. Data products that have both categorical and continuous data values (e.g. MOD15A2H) are not able to be displayed in the visualizations within AppEEARS.  

## 4. Area Sample Naming Convention  

Output data files returned by AppEEARS have the following naming convention:  


`<ProductShortName>.<Version>_<Resolution>_<AppEEARSFeatureID>.<FileFormat>`

### Example output file name (.nc)  

    MOD13Q1.061_250m_aid0002.nc  

**where:**

    <ProductShortName> .......... MOD13Q1  
    <Version> ................... 061  
    <Resolution> ................ 250m  
    <AppEEARSFeatureID> ......... aid0002  
    <FileFormat> ................ nc
The AppEEARS Feature ID is assigned automatically by the system.  

## 5. Data Quality  

When available, AppEEARS extracts and returns quality assurance (QA) data for each data file returned regardless of whether the user requests it. This is done to ensure that the user possesses the information needed to determine the usability and usefulness of the data they get from AppEEARS. Most data products available through AppEEARS have an associated QA data layer. Some products have more than one QA data layer to consult. See below for more information regarding data collections/products and their associated QA data layers.  

### 5.1. MODIS (Terra, Aqua, & Combined)  

All MODIS land products, as well as the MODIS Snow Cover Daily product, include quality assurance (QA) information designed to help users understand and make best use of the data that comprise each product.  

- See the MODIS Land Products QA Tutorials: <https://lpdaac.usgs.gov/resources/e-learning/> for more QA information regarding each MODIS land product suite.
- See the MODIS Snow Cover Daily product user guide for information regarding QA utilization and interpretation.

**NOTE:**  

- The Version 6.1 Aqua and Terra MODIS Net Evapotranspiration data products (MOD16s and MYD16s), Gross Primary Productivity data products (MOD17s and MYD17s), in addition to Terra MODIS Leaf Area Index/FPAR (MOD15A2H) include data layers with multiple fill values describing the category of non-vegetated pixels;
SRTM v3 products are accompanied by an ancillary "NUM" file in place of the QA/QC files. The "NUM" files indicate the source of each SRTM pixel, as well as the number of input data scenes used to generate the SRTM v3 data for that pixel.  

- See the user guide: <https://lpdaac.usgs.gov/documents/179/SRTM_User_Guide_V3.pdf> for additional information regarding the SRTM "NUM" file.

### 5.3. NASA VIIRS (Suomi National Polar-orbiting Partnership (Suomi NPP) & NOAA-20)  

All NASA VIIRS land products include quality information designed to help users understand and make best use of the data that comprise each product. For product-specific information, see the link to the NASA VIIRS products table provided in section 6.  

**NOTE:**  

- The version 2 Suomi NPP NASA VIIRS Surface Reflectance data products VNP09A1 and VNP09H1 contain two quality layers: `SurfReflect_State` and `SurfReflect_QC`. Both quality layers are provided to the user with the request results. 

- The Version 2 Suomi NPP and NOAA-20 Actual and Potential Evapotranspiration data products (VNP16s and VJ116s) in addition to Suomi NPP Leaf Area Index/FPAR (VNP15A2H) include data layers with multiple fill values describing the category of non-vegetated pixels; however, the data attributes in the source header file specify only one fill value. AppEEARS area requests return unscaled data consistent with the source products, so users should mask the additional fill values prior to scaling.  

### 5.4. SMAP  

SMAP products provide multiple means to assess quality. Each data product contains bit flags, uncertainty measures, and file-level metadata that provide quality information. Results downloaded from AppEEARS and/or data directly requested via middleware services contain not only the requested pixel/data values, but also the decoded bit flag information associated with each pixel/data value extracted. For additional information regarding the specific bit flags, uncertainty measures, and file-level metadata contained in this product, refer to the Quality Assessment section of the user guide for the specific SMAP data product in your request: <https://nsidc.org/data/smap/smap-data.html>.  

### 5.5. Daymet v4R1

Daymet station-level daily weather observation data and the corresponding Daymet model predicted data for three Daymet model parameters: minimum temperature (tmin), maximum temperature (tmax), and daily total precipitation (prcp) are available. These data provide information into the regional accuracy of the Daymet model for the three station-level input parameters. Corresponding comma separated value (.csv) files that contain metadata for every surface weather station for the variable-year combinations are also available. <https://doi.org/10.3334/ORNLDAAC/2129>

### 5.6.1. ECOSTRESS Swath V2

V2: Quality information varies by product for the ECOSTRESS product suite. Quality Assurance (QA) information for ECO_L2_LSTE.002, including the bit definition index for the quality layer, is provided in section 2.4 of the User Guide: <https://lpdaac.usgs.gov/documents/1574/ECOL2_User_Guide_V2.pdf>. For Land Surface Temperature and Emissivity (LSTE) product, the quality flags of the source data are available in the ECO_L2_LSTE.002 data product. Please note that unlike V1, the V2 LSTE product does not incorporate cloud cover into the Pixel Produced QA bit flag. This flag now relates to other variables only (See Table 6 in User Guide). Users should apply the cloud mask separately to account for pixels with cloud when using ECO_L2_LSTE.002 data product.  Cloud mask derived from ECO_L2_CLOUD.002 is and Water mask derived from the Shuttle Radar Topography Mission (SRTM) Digital Elevation Model are available as separate science dataset (SDS) layers in the ECO_L2_LSTE.002 data product. Additionally, cloud and cloud confidence layers are available in the ECO_L2_CLOUD.002 product. Results downloaded from AppEEARS contain requested pixel/data values,` decoded Quality Assurance (QA), and cloud information associated with each pixel/data value extracted.

### 5.6.2. ECOSTRESS Tiled V2  

Quality information varies by product for the ECOSTRESS product suite. Quality information for ECO_L2T_LSTE.002, including the bit definition index for the quality layer, is provided in section 2.4 of the User Guide: <https://lpdaac.usgs.gov/documents/1574/ECOL2_User_Guide_V2.pdf>. Results downloaded from AppEEARS contain requested pixel/data values and decoded QA information associated with each pixel/data value extracted. For Land Surface Temperature and Emissivity (LSTE) product, the quality flags of the source data are available as a separate SDS layer in the ECO_L2T_LSTE.002 collection, however this Pixel Produced QA bit flags do not account for cloud cover. Users should apply the cloud mask separately to account for pixels with cloud when using ECO_L2T_LSTE.002 collection. In addition to decoded quality information, AppEEARS returns the cloud mask information for requests including layers from ECO_L2T_LSTE.002.

For high-level products, Cloud mask derived from ECO_L2_CLOUD.002 and Water mask derived from the Shuttle Radar Topography Mission (SRTM) Digital Elevation Model are available as separate science dataset (SDS) layers in the ECO_L2T_LSTE.002 data product.

### 5.7. ASTER GDEM v3 and Global Water Bodies Database v1  

ASTER GDEM v3 data are accompanied by an ancillary "NUM" file in place of the QA/QC files. The "NUM" files refer to the count of ASTER Level-1A scenes that were processed for each pixel or the source of reference data used to replace anomalies. The ASTER Global Water Bodies Database v1 products do not contain QA/QC files.  

- See Section 7 of the ASTER GDEM user guide: <https://lpdaac.usgs.gov/documents/434/ASTGTM_User_Guide_V3.pdf> for additional information regarding the GDEM "NUM" file.  
- See Section 7 of the ASTER Global Water Bodies Database user guide: <https://lpdaac.usgs.gov/documents/436/ASTWBD_User_Guide_V1.pdf> for a comparison with the SRTM Water Body Dataset.

### 5.8. NASA MEaSUREs NASADEM v1 (30m)  

NASADEM v1 products are accompanied by an ancillary "NUM" file in place of the QA/QC files. The "NUM" files indicate the source of each NASADEM pixel, as well as the number of input data scenes used to generate the NASADEM v1 data for that pixel.  

- See the NASADEM user guide: <https://lpdaac.usgs.gov/documents/592/NASADEM_User_Guide_V1.pdf> for additional information regarding the NASADEM "NUM" file.  

### 5.9. HLS v2.0  

HLS v2.0 Operational Land Imager (OLI) Surface Reflectance and TOA Brightness Daily Global 30m (HLSL30 v002) and Sentinel-2 Multi-spectral Instrument (MSI) Surface Reflectance Daily Global 30m (HLSS30 v002) products have a quality assessment layer enabling per-pixel masking of cloud, cloud shadow, snow, water, and aerosol optical thickness levels. Quality information for HLSL30 v002 and HLSS30 v002 products, including bit definitions for the quality layer can be found in section 6.4 of the User Guide: <https://lpdaac.usgs.gov/documents/1326/HLS_User_Guide_V2.pdf>.  

### 5.10. Landsat Collection 2 ARD

Landsat C2 U.S. Analysis Ready Data (ARD) products are available for conterminuous United States (CONUS)(1982-Present), Alaska (1984-present), and Hawaii (1989-1993, 1999-present). These data are products of Landsat 8/9 Operational Land Imager 2 (OLI-2) / Thermal Infrared Sensor 2 (TIRS-2), Landsat 7 Enhanceted Themattic Mapper Plus (ETM+) and Landsat 4-5 Thematic Mapper (TM). The ARD significantly reduces the magnitude of data processing for application scientiests. These data contain a pixel quality assessment derived from Fmask version 3.3.1, Aerosol and Cloud QA derived from atmospheric compensation algorithms, and radiometric saturation QA derived from detector's input signal level. More details can be found in the Landsat Collection 2 U.S. ARD DFCB: <https://d9-wret.s3.us-west-2.amazonaws.com/assets/palladium/production/s3fs-public/media/files/LSDS-1435%20Landsat%20C2%20US%20ARD%20Data%20Format%20Control%20Book-v3.pdf>

### 5.11. US NPS Water Balance

The US NPS Historical Water Balance products do not have associated QA files or layers.

### 5.12. EMIT L1B Radiance and L2A Reflectance

EMIT L1B At-Sensor Calibrated Radiance and Geolocation Data 60m (EMITL1BRAD) collection does not include quality information. EMIT L2A Estimated Surface Reflectance and Uncertainty and Masks 60m (EMITL2ARFL) collection does not have a direct quality assessment, but the Reflectance Uncertainty product (EMIT_L2A_RFLUNCERT) contains uncertainty estimates about the reflectance captured as per-pixel, per-band posterior standard deviations, and the EMIT L2A Mask (EMIT_L2A_Mask) contains atmospheric state estimates and binary flags that can be used for quality filtering. More details about the EMIT_L2A_Mask can be found in the EMITL2ARFL User Guide: <https://lpdaac.usgs.gov/documents/1569/EMITL2ARFL_User_Guide_v1.pdf>

### 5.13. EMIT L2B Estimated Mineral Identification, Band Depth and Uncertainty

EMIT L2B Estimated Mineral Identification, Band Depth and Uncertainty 60m ([EMITL2BMIN](https://doi.org/10.5067/EMIT/EMITL2BMIN.001)) collection is generated using the [Tetracorder system](https://www.usgs.gov/publications/tetracorder-user-guide-version-44?_gl=1*1eoj33d*_ga*MTU3MTA3ODgxNS4xNjQ5MTg1MDgx*_ga_0YWDZEJ295*MTY4NjkyNTg0Mi40NC4xLjE2ODY5MjU4NzMuMC4wLjA.) ([code](https://github.com/PSI-edu/spectroscopy-tetracorder)). Quality information is included in the Uncertainty product (EMITL2BMINUNCERT). This product contains band depth uncertainty estimates and a fit score for the mineral identification. Band depth uncertainties are presented as standard deviations and the fit score is provided as the coefficient of determination (r^2) of the match between the continuum normalized library reference and the continuum normalized observed spectrum.  

## 6. Data Caveats  

### 6.1.1. ECOSTRESS Swath V2  

- ECOSTRESS Swath data products are natively stored in swath format. To fulfill AppEEARS requests for ECOSTRESS Swath products, the data are first resampled from the native swath format to a georeferenced output. This requires the use of the requested ECOSTRESS product files and the corresponding ECO1BGEO: <https://doi.org/10.5067/ECOSTRESS/ECO1BGEO.001> files for all ECOSTRESS Swath products. To do this conversion, an index array and distance array are created, then the nearest area pixel is located. Next, the Euclidean distance to that area pixel plus all surrounding pixels is measured within a 210 meter search radius (+/- a 3 pixels). This results in 49 pixels measured for every swath pixel. If the distance measured is less than what's currently present in any distance array, then the new distance as well as the swath index value are recorded into the index array used to convert to an area output.  

### 6.1.2. ECOSTRESS Tiled Version 2  

- ECOSTRESS Tiled data products are stored as cloud optimized geotiffs tiled based on the Military Grid Reference System (MGRS) to standardize data for ease of use in time-series analyses. The tiles are delivered in a Universal Transverse Mercator (UTM) projection. More detail can be found in the User Guide: <https://lpdaac.usgs.gov/documents/423/ECO2_User_Guide_V2.pdf>.  
- Multiple ECOSTRESS v2 Tiled granules can exist per day for the same tile as a result of the ISS orbit. Since variables like surface temperature are highly time-dependent, tiles are only merged if they fall within the same UTM zone and have the same timestamp (both tiles are from the same orbit and scene). Merging is done using the `merge` function from the `rasterio` Python package. Please note, there are overlap in ECOSTRESS Source Tiled data and pixels do not align. Therefore, relatively slight pixel shift is expected in AppEEARS outputs.  
- It is not uncommon for many pixels returned to contain NaN values. If any layer requested or the QC layer contains valid data, the remaining requested layers will be returned even if only NaN values are present.  

### 6.2. Suomi NPP VIIRS Land Surface Phenology Product (VNP22Q2)  

- A subset of the science datasets/variables for VNP22Q2 are returned in their raw, unscaled form. That is, these variables are returned without having their scale factor and offset applied. AppEEARS visualizations and output summary files are derived using the raw data value, and consequently do not characterize the intended information ("day of year") for the impacted variables. The variables returned in this state include:  

    1. Date_Mid_Greenup_Phase (Cycle 1 and Cycle 2)  
    2. Date_Mid_Senescence_Phase (Cycle 1 and Cycle 2)  
    3. Onset_Greenness_Increase (Cycle 1 and Cycle 2)  
    4. Onset_Greenness_Decrease (Cycle 1 and Cycle 2)  
    5. Onset_Greenness_Maximum (Cycle 1 and Cycle 2)  
    6. Onset_Greenness_Minimum (Cycle 1 and Cycle 2)  

- To convert the raw data to "day of year" (doy) for the above variables, use the following equation:  

      doy = Raw_Data_Value * 1 – (Given_Year - 2000) * 366

### 6.3 SMAP

#### 6.3.1. SMAP Enhanced L3 Radiometer Global and Polar Grid Daily 9 km EASE-Grid Soil Moisture (SPL3SMP_E)

- The SPL3SMP_E includes additional layers for AM and PM north-polar grid soil moisture retrievals. These additional layers are not supported in AppEEARS.

#### 6.3.2. SMAP L4 Global 3-hourly 9 km EASE-Grid Surface and Root Zone Soil Moisture Geophysical Data (SPL4SMGP)

- The SPL4SMGP provides 3-hourly data within a single day. AppEEARS COG output files specify the observation date as day of the year (`YYYYDOY`) in the filename followed by time information (`HHMMSS`). 
     - Example: `SPL4SMGP.008_Geophysical_Data_sm_surface_doy2025134013000_aid0001.tif`

- For NetCDF output files, AppEEARS specifies the observation date then time stamps in the file.

### 6.4. HLS v2.0  

- HLS has adopted a gridded tiling system based on the Military Grid Reference System (MGRS) to standardize data for ease of use in time-series analyses. The tiles are delivered in a Universal Transverse Mercator (UTM) projection. More detail can be found in the User Guide: <https://lpdaac.usgs.gov/documents/1326/HLS_User_Guide_V2.pdf>.
- Scenes are merged using the `merge` function from the `rasterio` Python package if they fall within the same UTM zone.  
- When requesting HLS timeseries, note that Sentinel-2 launched after Landsat was already active. Landsat OLI (HLSL30 v002) products are available from 2013-04-11 to present, while Sentinel-2 MSI products (HLSS30 v002) are available from  2015-11-30 to present.  
- Extra granules from outside the region of interest specified may appear in the granule list if the region of interest is close to an area where MGRS tiles overlap.
- Historical processing of the HLS Vegetation Indices (VI) products (HLSS30_VI v002 and HLSL30_VI v002) has not started as of May 9, 2025. Data currently available in AppEEARS is from February 6, 2025 to present.

### 6.5. MOD44B V6.1

- Value zero in the Cloud and Quality layers from MOD44B Version 6.1 Vegetation Continuous Fields (VCF) yearly product is assigned to Fill Value in the source file while value zero is meaningful for those layers. If comparing Cloud and Quality layers outputs with source files, users may notice that within the source files zero is assigned to fill value, however zero is within the valid range. Thus, AppEEARS outputs Use -999 as a fill value for those layers.

### 6.6. EMIT L1B Radiance and L2A Reflectance

- The EMIT mission is focused on collecting data from land arid dust source regions, meaning that coverage is limited to those regions based upon a mask. You can explore coverage and forecasted coverage using Jet Propulsion Laboratory's [Visions: EMIT Open Data Portal](https://earth.jpl.nasa.gov/emit/data/data-portal/coverage-and-forecasts/)
- Both EMIT L1B Radiance and L2A Reflectance collections are natively provided in spatially raw, non-orthorectified format, but have an included geometry lookup table (GLT). The GLT is two-layered orthorectified (EPSG:4326) grid in the 'location' group of the NetCDF4 file that contains cross-track and down-track pixel indices that can be used to quickly and consistently orthorectify the radiance or reflectance products.
- EMIT area outputs are not mosaicked, each scene is subset to the specified region(s) and users can make the decision whether mosaicking adjacent scenes is appropriate.
- There are several output choices for EMIT area outputs. They can be requested as either netCDF4 format, or ENVI binary format with a header. Additionally, users may request area samples that are orthorectified or spatially raw (non-orthorectified) with a GLT.
- Elevation data is always included in requests. For API users there is an additional 'elev' layer listed, but that layer cannot be requested. This has to be present due to some constraints of AppEEARS' backend.

### 6.7. EMIT L2B Estimated Mineral Identification, Band Depth and Uncertainty

- The EMIT_L2B_MIN product is generated to support the EMIT mission objectives of constraining the sign of dust-related radiative forcing. Ten mineral types are the core focus of this work: Calcite, Chlorite, Dolomite, Goethite, Gypsum, Hematite, Illite+Muscovite, Kaolinite, Montmorillonite, and Vermiculite. Additional minerals are included in this product for transparency but were not the focus of this product. Further validation is required to use these additional mineral maps, particularly in the case of resource exploration. Similarly, the separation of minerals with similar spectral features, such as a fine-grained goethite and hematite, is an active research area. The results presented here are an initial offering, but the precise categorization is likely to evolve, and the limits of what can and cannot be separated on a global scale are still being explored. The user is encouraged to read the Algorithm Theoretical Basis Document ([ATBD](https://lpdaac.usgs.gov/documents/1659/EMITL2B_ATBD_v1.pdf)) for more details.  
- The EMIT L2B Mineral Identification, Band Depth and Uncertainty collection is natively provided in spatially raw, non-orthorectified format, but have an included geometry lookup table (GLT). The GLT is two-layered orthorectified (EPSG:4326) grid in the 'location' group of the NetCDF4 file that contains cross-track and down-track pixel indices that can be used to quickly and consistently orthorectify the data variables.  
- EMIT area outputs are not mosaicked, each scene is a subset to the specified region(s) and users can decide whether mosaicking adjacent scenes is appropriate.  
- There are several output choices for EMIT area outputs. They can be requested as either netCDF4 format or ENVI binary format with a header. Additionally, users may request area samples that are orthorectified or spatially raw (non-orthorectified) with a GLT.  
- Elevation data is always included in requests. For API users there is an additional 'elev' layer listed, but that layer cannot be requested. This has to be present due to some constraints of AppEEARS' backend.

## 7. Documentation  

The documentation for AppEEARS can be found at <https://appeears.earthdatacloud.nasa.gov/help>.  

Documentation for data products available through AppEEARS are listed below.  

### 7.1. MODIS Land Products(Terra, Aqua, & Combined)  

- <https://www.earthdata.nasa.gov/data/catalog?keyword=MODIS%20LP%20DAAC>  

### 7.2. MODIS Snow Products (Terra and Aqua)  

- <https://nsidc.org/data/modis/data_summaries>  

### 7.3. NASA MEaSUREs SRTM v3  

- <https://doi.org/10.5067/MEASURES/SRTM/SRTMGL1.003>  
- <https://doi.org/10.5067/MEASURES/SRTM/SRTMGL1N.003>  
- <https://doi.org/10.5067/MEaSUREs/SRTM/SRTMGL3.003>  
- <https://doi.org/10.5067/MEASURES/SRTM/SRTMGL3N.003>  


### 7.4. NASA VIIRS Land Products (Includes Suomi NPP & NOAA-20)  

- <https://www.earthdata.nasa.gov/data/catalog?keyword=VIIRS%20LP%20DAAC>  

### 7.5. SMAP Products  

- <http://nsidc.org/data/smap/smap-data.html>  

### 7.6. Daymet v4R1

- <https://doi.org/10.3334/ORNLDAAC/2129>
- <https://daymet.ornl.gov/>

### 7.7. ECOSTRESS  

- <https://www.earthdata.nasa.gov/data/catalog?keyword=ECOSTRESS&page_num=4>  

### 7.8. ASTER GDEM v3 and Global Water Bodies Database v1  

- <https://doi.org/10.5067/ASTER/ASTGTM.003>  
- <https://doi.org/10.5067/ASTER/ASTWBD.001>  

### 7.9. NASADEM v1  

- <https://doi.org/10.5067/MEaSUREs/NASADEM/NASADEM_NC.001>  
- <https://doi.org/10.5067/MEaSUREs/NASADEM/NASADEM_NUMNC.001>

### 7.10. HLS v2.0  

- <https://lpdaac.usgs.gov/product_search/?collections=HLS&view=list>  
- <https://doi.org/10.5067/HLS/HLSL30.002>  
- <https://doi.org/10.5067/HLS/HLSS30.002>

### 7.11. Landsat ARD

- <https://doi.org/10.5066/P960F8OC>

### 7.12. US NPS Water Balance

- [User Guide](https://screenedcleanedsummaries.s3.us-west-2.amazonaws.com/Gridded_Water_Balance_Model_April_2021.pdf)

### 7.13. EMIT L1B Radiance and L2A Reflectance

- <https://doi.org/10.5067/EMIT/EMITL1BRAD.001>
- <https://doi.org/10.5067/EMIT/EMITL2ARFL.001>

### 7.14. EMIT L2B Estimated Mineral Identification, Band Depth and Uncertainty

- <https://doi.org/10.5067/EMIT/EMITL2BMIN.001>

### 7.15.  NASA VIIRS Snow Products (Includes Suomi NPP & NOAA-20)

- <https://doi.org/10.5067/45VDCKJBXWEE>

## 8. Sample Request Retention  

AppEEARS sample request outputs are available to download for a limited amount of time after completion. Please visit <https://appeears.earthdatacloud.nasa.gov/help?section=sample-retention> for details.  

## 9. Data Product Citations  

- Garcia, H., Graffy, P., Barret, B., Visa, M., Jia, J., Mallen, E., Mansour, R., Briggs, G., Ford, T., Wuebbles, D., Allen, N., Horton, T., Kho, A., & Horton, D. (2026). Increasing urban tree canopy associated with reduced mortality: a longitudinal analysis of Chicago neighborhoods. Prism. Galter Health Sciences Library. Northwestern University. https://doi.org/10.18131/9QK28-7C319

Garcia, H., Graffy, P., Barret, B., Visa, M., Jia, J., Mallen, E., Mansour, R., Briggs, G., Ford, T., Wuebbles, D., Allen, N., Horton, T., Kho, A., & Horton, D. (2026). Increasing urban tree canopy associated with reduced mortality: a longitudinal analysis of Chicago neighborhoods. Prism. Galter Health Sciences Library. Northwestern University. https://doi.org/10.18131/5R2WN-3EW10

Bischof, B. (2025). CONUS soil moisture and attribute dataset. Zenodo. https://doi.org/10.5281/ZENODO.18016490

Bischof, B. (2025). CONUS soil moisture and attribute dataset. Zenodo. https://doi.org/10.5281/ZENODO.18016491

Kovacek, D. (2025). Processed Catchment-Averaged Meteorological Forcings from Daymet for Streamflow Monitored Catchments in British Columbia and Transboundary Basins (Version 2.0). Borealis. https://doi.org/10.5683/SP3/65FXAS

Schönberger, D. (2025). Daymet V4 Monthly Mean Daylength (2024) — North America (Native Lambert Conformal Conic, 1 km). Zenodo. https://doi.org/10.5281/ZENODO.17468682

Schönberger, D. (2025). Daymet V4 Monthly Mean Daylength (2024) — North America (Native Lambert Conformal Conic, 1 km). Zenodo. https://doi.org/10.5281/ZENODO.17468681

Thornton, M. M., Shrestha, R., Wei, Y., Thornton, P. E., & Kao, S.-C. (2022). Daymet: Daily Surface Weather Data on a 1-km Grid for North America, Version 4 R1 (Version 4.1). ORNL Distributed Active Archive Center. https://doi.org/10.3334/ORNLDAAC/2129

Rastogi, D., Niu, H., & Kao, S.-C. (2025). Artificial Intelligence-Enhanced CMIP6 Climate Projections Across the Conterminous United States. Oak Ridge National Laboratory (ORNL), Oak Ridge, TN (United States). Oak Ridge Leadership Computing Facility (OLCF); Oak Ridge National Laboratory (ORNL), Oak Ridge, TN (United States). https://doi.org/10.13139/OLCF/2530405. Accessed February 13, 2026.

## 10. Software Citation  

AppEEARS Team. (2026). Application for Extracting and Exploring Analysis Ready Samples (AppEEARS). Ver. 3.110. NASA EOSDIS Land Processes Distributed Active Archive Center (LP DAAC), USGS/Earth Resources Observation and Science (EROS) Center, Sioux Falls, South Dakota, USA. Accessed February 13, 2026. https://appeears.earthdatacloud.nasa.gov

## 11. Feedback  

We value your opinion. Please help us identify what works, what doesn't, and anything we can do to make AppEEARS better by submitting your feedback at <https://appeears.earthdatacloud.nasa.gov/feedback> or to LP DAAC User Services at <https://lpdaac.usgs.gov/lpdaac-contact-us/>.

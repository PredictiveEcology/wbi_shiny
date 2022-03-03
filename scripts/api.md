# File server and API

- [File server and API](#file-server-and-api)
  - [Terminology](#terminology)
  - [Paths](#paths)
  - [Elements](#elements)
  - [Linking to file server from R](#linking-to-file-server-from-r)

The deployment consists of a static file folder. This serves as a static API (supporting only GET requests at the moment). This serves the downloadable files and the TMS tiles displayed by the apps.

This file server can share the same domain name or IP address as the server hosting the apps, and it can also be a different domain.

This section describes the logic of how files are organized.

## Terminology

Based on the review of the data and requirements from discussions, the following organizing framework was determined to serve the needs of the application backend and facilitate future extensions and updates.

- **Access**: access level, i.e. public vs private. We can restrict access to private assets via reverse proxy and password protection (available for the app, if certain parts of the app will be password protected, the corresponding data assets need to be protected as well)
- **Project**: the current extent of Northwest Territories (NWT), future extents might include larger areas, this is the boundary that encompasses the other considerations. This “root level” isolation allows extending/replicating the framework later.
- **Elements**: abiotic variables (climate variables), species (tree species, mammals, birds, other plants)
- **Treatment**: forecasting/simulation settings, e.g. no climate change, climate-sensitive etc. These are factorial design setups under which e.g. elements are to be compared
- **Period**: time period for a given element & treatment combination, e.g. base year, end year of simulations
- **Resolution/tiles**: raster resolution for download (250m, 1000m), tiles (tiled png files)
- **Regions**: nested boundaries within the extent, we can provide summary statistics for element/treatment/period combinations to be compared in plots/tables. The statistics (mean, median, sum, std. deviation) will depend on the element.


## Paths

Paths follow from the terminology and capture a logical way of how to organize the data in a predictable manner.

`<PROTOCOL>://<HOST>/api/<VERSION>/<ACCESS>/<PROJECT>/<KIND>/<ELEMENT>/<SCENARIO>/<PERIOD>/<RESOLUTION>/<FILE.EXT>`.

- `PROTOCOL`: protocol name, `http` or `https`
- `HOST`: IP address (`178.128.225.41`) or domain name (`wbi-nwt.analythium.ap`)
- `VERSION`: API version, `v1`
- `ACCESS`: access level, `public` is not password protected, `private` is intended to be password protected (this will house sensitive information with similar nested structure)
- `PROJECT`: a project, e.g. `wbi-nwt`
- `KIND`: the kind of information being displayed, `elements` or `summaries`
- `ELEMENT`: element name (bird or tree species abbreviation), e.g. `bird-alfl` or `tree-betu-pap`
- `SCENARIO`: screnario or treatment type (`landr-scfm-v4`, `landrcs-fs-v6a`)
- `PERIOD`: time period, i.e. year (`2011`, `2100`)
- `RESOLUTION`: resolution (`250m` or `1000m`) or `tiles`
- `FILE.EXT`: file name, e.g. `mean.tif` meaning that the pixel values are the mean of 10 runs

Example: <https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/bird-alfl/landr-scfm-v4/2011/1000m/mean.tif>

## Elements

Let's review whet is available for each element (species).

The element's root path for a given scenario and time period is say `PATH="https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/bird-alfl/landr-scfm-v4/2011"`. Relative to this, we provide following structure:

- `$PATH/250m/mean.tif`: 250 m resolution mean raster
- `$PATH/1000m/mean.tif`: 1 km resolution mean raster
- `$PATH/tiles`: TMS tiles (nested folders and PNG files with an XML metadata containing info about the bounding box and units at different zoom levels)
- `$PATH/preview.html`: a HTML/Leaflet preview of the tiled data

Examples:

Browsing is enabled on the file server, check the structure for the tiles:
<https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/bird-alfl/landr-scfm-v4/2011/tiles>

Leaflet preview:
<https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/bird-alfl/landr-scfm-v4/2011/preview.html>

GeoTIFF:
<https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/bird-alfl/landr-scfm-v4/2011/1000m/mean.tif>

## Linking to file server from R

Accessing tif iles:

```R
library(raster)
f <- "http://178.128.225.41/api/v1/public/wbi-nwt/elements/bird-alfl/landr-scfm-v4/2011/1000m/mean.tif"

r <- raster(f)
plot(r)
```

Displaying raster tiles:

```R
library(leaflet)
tiles <- "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/tree-betu-pap/landr-scfm-v4/2011/tiles/{z}/{x}/{y}.png"

leaflet(
  options = leafletOptions(minZoom = 0, maxZoom = 10, tms = TRUE), width = "100%") %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addTiles(
    urlTemplate = tiles,
    options = tileOptions(opacity = 0.8, minZoom = 0, maxZoom = 10, tms = TRUE)) %>% 
  setView(-100, 60, 0)
```

library(sf)
library(raster)

## This is our raster template
## Projection is a Lambers conical conformal by NRCan
# https://epsg.io/42309
# +proj=lcc +lat_0=0 +lon_0=-95 +lat_1=49 +lat_2=77 +x_0=0 +y_0=0 +ellps=GRS80 +units=m +no_defs
r <- raster("data/raster-template-NWT.tif")

## Unioned region sf data frame
p <- st_read("data/regions/regions.gpkg")
## cutoff: 10 km^2
p <- p[p$area >= 10^6 * 10,]

## Get element data
baseurl <- "https://wbi-nwt.analythium.app"

d <- jsonlite::fromJSON(
    file.path(baseurl, "/api/v1/public/wbi-nwt/elements/index.json"))
## use 250 m resolution for summaries
d <- d[d$resolution == "250m",]

## iterate over rows in d
i <- 1

## read in the raster
ri <- raster(file.path(baseurl, d$path[i]))

## iterate over rows in p
j <- 7

## boundary
b <- p[j,]

## mask raster by boundary and trim to extent
ric <- trim(mask(ri, b))

# plot(ric)
# plot(b$geom, add=TRUE)

## calculate the
## - mean inside the boundary
## - area inside the boundary (Npix * 250^2 in meters)
## we can then calculate the sum by mean * area later if needed

Npix <- sum(!is.na(values(ric)))
Mean <- mean(values(ric), na.rm=TRUE)
Min <- min(values(ric), na.rm=TRUE)
Max <- max(values(ric), na.rm=TRUE)

## Now save these stats with the i & j related metadata in a file/DB
## This can be stored on the server for programmatic use
## but needs to be present locally for faster access.
## I suggest parquet, SQLite, or qs

## This file contain scripts to delineate the WBI NWT study area
## and clip other layers to this extent.
## These will then serve as boundaries for regional summaries.

library(sf)
library(raster)

## This is our raster template
## Projection is a Lambers conical conformal by NRCan
# https://epsg.io/42309
# +proj=lcc +lat_0=0 +lon_0=-95 +lat_1=49 +lat_2=77 +x_0=0 +y_0=0 +ellps=GRS80 +units=m +no_defs
r <- raster("data/raster-template-NWT.tif")

## Canada & NWT boundary
## Use province/territory map for cartography
f <- "data/boundaries/lpr_000b16a_e/lpr_000b16a_e.shp"
x <- st_read(f)
x <- st_transform(x, st_crs(r))

# o <- "canada"
# png(sprintf("data/regions/%s.png", o))
# plot(x$geometry)
# dev.off()
# st_write(x, sprintf("data/regions/%s.gpkg", o))

x <- x[x$PRNAME=="Northwest Territories / Territoires du Nord-Ouest",]

# o <- "nwt"
# png(sprintf("data/regions/%s.png", o))
# plot(x$geometry)
# dev.off()
# st_write(x, sprintf("data/regions/%s.gpkg", o))

## Terrestrial Bird Conservation Regions (BCR)
## clip BCRs to NWT
f <- "data/boundaries/bcr_terrestrial_shape/BCR_Terrestrial_master_International.shp"
st_layers(f)
z <- st_read(f)
z <- st_transform(z, st_crs(r))

## BCR 6 in NWT is our study area
z <- st_intersection(z, x)
z <- z[z$BCR==6,]
o <- "nwt-bcr6"
png(sprintf("data/regions/%s.png", o))
plot(z$geometry)
dev.off()
st_write(z, sprintf("data/regions/%s.gpkg", o))

## Ecodistricts
f <- "data/boundaries/Ecodistricts/ecodistricts.shp"
st_layers(f)
x <- st_read(f)
x <- st_transform(x, st_crs(r))
x <- st_intersection(x, z)

o <- "ecodistricsts-in-nwt-bcr6"
png(sprintf("data/regions/%s.png", o))
plot(x$geometry)
dev.off()
st_write(x, sprintf("data/regions/%s.gpkg", o))

## Protected areas
f <- "data/boundaries/CPCAD-BDCAPC_Dec2021.gdb"
st_layers(f)
x <- st_read(f, "CPCAD_BDCAPC_Dec2021")
x <- st_transform(x, st_crs(r))
x <- st_intersection(x, z)
x <- x[,setdiff(names(x), names(z))]
x[["Shape_Length"]] <- x[["Shape_Area.1"]] <- NULL

o <- "protected-areas-in-nwt-bcr6"
png(sprintf("data/regions/%s.png", o))
plot(x$Shape)
dev.off()
st_write(x, sprintf("data/regions/%s.gpkg", o))

## Important Wildlife Areas NWT
f <- "data/boundaries/Important_Wildlife_Areas_NWT/v93/sdw_data0.gdb"
s <- st_layers(f)
xx <- NULL
for (i in s[[1]]) {
    message(i)
    x <- st_read(f, i)
    x$layer <- i
    x <- st_transform(x, st_crs(r))
    x <- st_intersection(x, z)
    if (nrow(x))
        xx <- rbind(xx, x[,c("IWA", "layer", "Shape")])
}
o <- "iwa-in-nwt-bcr6"
png(sprintf("data/regions/%s.png", o))
plot(xx$Shape, border=as.factor(xx$layer))
dev.off()
st_write(xx, sprintf("data/regions/%s.gpkg", o))

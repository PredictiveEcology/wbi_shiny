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
x <- x[x$LOC_E == "Northwest Territories",]
any(duplicated(x$NAME_E))

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

## Caribou areas / meta-herds
f <- "data/boundaries/Johnsonetal2020_studyareas/Enhanced_MetaHerds_20191029.shp"
x <- st_read(f)
x <- st_transform(x, st_crs(r))
x <- x[x$PROV_TERR=="NWT",]
x <- st_intersection(x, z)

o <- "caribou-metaherds-nwt-bcr6"
png(sprintf("data/regions/%s.png", o))
plot(x$geometry, border=as.factor(x$HERD))
dev.off()
st_write(x, sprintf("data/regions/%s.gpkg", o))

## combine regions into a single sf object

library(sf)
library(dplyr)

p0 <- st_read("data/regions/nwt-bcr6.gpkg")
p0$classification <- "NWT"
p0$region <- "Northwest Territories"
p0$area <- st_area(p0)

p1 <- st_read("data/regions/ecodistricsts-in-nwt-bcr6.gpkg")
p1 <- p1 |> group_by(ECOREGION) |> summarize()
p1$classification <- "Ecoregions"
p1$region <- as.character(p1$ECOREGION)
p1$ECOREGION <- NULL
p1$area <- st_area(p1)
p1 <- p1[!(p1$region %in% c("35", "68")),]

p2 <- st_read("data/regions/protected-areas-in-nwt-bcr6.gpkg")
p2$classification <- "Protected Areas"
p2$region <- p2$NAME_E
p2$area <- st_area(p2)
p2 <- p2[names(p1)]

p3 <- st_read("data/regions/iwa-in-nwt-bcr6.gpkg")
p3$layer <- gsub("BIO_ENR_WFE_", "", p3$layer)
p3$layer <- gsub("_", " ", p3$layer)
p3$region <- p3$layer
p3 <- p3 |> group_by(region) |> summarize()
p3$classification <- "IWA"
p3$area <- st_area(p3)
p3 <- p3[names(p1)]
p3 <- p3[!(p3$region %in% c("MINERALLICKDENSITY IWA", "BARRENGROUNDCARIBOU IWA")),]


p4 <- st_read("data/regions/caribou-metaherds-nwt-bcr6.gpkg")
p4$classification <- "Caribou Meta-herds"
p4$region <- p4$StudyArea
p4$area <- st_area(p4)
p4 <- p4[names(p1)]

pp <- rbind(p0[,colnames(p1)], p1, p2, p3, p4)
pp <- pp[as.numeric(pp$area)/10^6 >= 250,]

## plot all the boundaries to check what to exclude
pf <- function(i) {
    p <- pp[i,]
    Main <- paste(p$classification, "/", p$region)
    Sub <- as.character(paste(round(p$area/10^6), "km^2"))
    message(Main)
    plot(pp[1,"geom"], main=paste(Main, Sub, sep="\n"))
    plot(pp[pp$classification == p$classification, "geom"], 
        border="grey", add=TRUE)
    plot(p$geom, col="gold", border="tomato", add=TRUE)
    invisible(NULL)
}

pdf("_tmp/regions.pdf", onefile=TRUE)
v <- which(as.numeric(pp$area) / 10^6 > 100)
for (i in v) {
    pf(i)
}
dev.off()

st_write(pp, "data/regions/regions.gpkg", delete_dsn=TRUE)
saveRDS(pp, "data/regions/regions.rds")


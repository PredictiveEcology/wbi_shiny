library(sf)
library(raster)

## This is our raster template
## Projection is a Lambers conical conformal by NRCan
# https://epsg.io/42309
# +proj=lcc +lat_0=0 +lon_0=-95 +lat_1=49 +lat_2=77 +x_0=0 +y_0=0 +ellps=GRS80 +units=m +no_defs
r <- raster("data/raster-template-NWT.tif")

## Unioned region sf data frame
p <- st_read("data/regions/regions.gpkg")

## Get element data
#baseurl <- "https://wbi-nwt.analythium.app"
baseurl <- "/Volumes/WD 2020831 A/tmp/wbi3out"

#d <- jsonlite::fromJSON(
#    file.path(baseurl, "/api/v1/public/wbi-nwt/elements/index.json"))
d <- read.csv("scripts/api-index.csv")

## use 250 m resolution for summaries
d <- d[d$resolution == "250m",]

OUT <- array(0, c(nrow(d), nrow(p), 4))
dimnames(OUT) <- list(
    gsub("/250m/mean.tif", "", gsub("api/v1/public/wbi-nwt/elements/", "", d$path)),
    paste0(p$classification, ": ", p$region),
    c("Npix", "Mean", "Min", "Max"))
rownames(d) <- dimnames(OUT)[[1]]
rownames(p) <- dimnames(OUT)[[2]]

## iterate over rows in d
#i <- 1
for (i in 1:nrow(d)) {

    path <- d$path[i]
    path <- gsub("api/v1/public/wbi-nwt/elements/", "", path)

    ## read in the raster
    ri <- raster(file.path(baseurl, path))

    ## iterate over rows in p
    #j <- 7
    for (j in 1:nrow(p)) {

        message(i, "/", nrow(d), " - ", j, "/", nrow(p))

        ## boundary
        b <- p[j,]

        ## mask raster by boundary and trim to extent
        ric <- mask(ri, b)

        # plot(ric)
        # plot(b$geom, add=TRUE)

        ## calculate the
        ## - mean inside the boundary
        ## - area inside the boundary (Npix * 250^2 in meters)
        ## we can then calculate the sum by mean * area later if needed

        OUT[i,j,"Npix"] <- sum(!is.na(values(ric)))
        OUT[i,j,"Mean"] <- mean(values(ric), na.rm=TRUE)
        OUT[i,j,"Min"] <- min(values(ric), na.rm=TRUE)
        OUT[i,j,"Max"] <- max(values(ric), na.rm=TRUE)

        ## Now save these stats with the i & j related metadata in a file/DB
        ## This can be stored on the server for programmatic use
        ## but needs to be present locally for faster access.
        ## I suggest parquet, SQLite, or qs
    }
}

# Give d and p rownames
# save all 3 objects

#save(d, p, OUT, file="_tmp/250m-Max.RData")
MAX <- list(elements=d, regions=p, statistics=OUT)
saveRDS(MAX, file="data/elements-regions-stats-250m.rds")
str(MAX)

MAX$statistics[grep("bird-alfl", dimnames(MAX$statistics)[[1]]), 1, ]

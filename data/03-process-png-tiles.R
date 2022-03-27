## Color palette: spectral for nonnegative domains, blue=low, yellow=mid, red=high
pal <- grDevices::hcl.colors(101, "spectral", rev = TRUE)

## color palettes: divergent for differences (real domains)
neg <- colorRampPalette(colors = c("darkred", "lightgoldenrod2"))(10)
pos <- colorRampPalette(colors = c("lightgoldenrod2", "darkblue"))(10)
pal2 <- c(neg, pos)

## truncation as needed
# q <- quantile(values(r), 0.999, na.rm=TRUE)
# values(r)[!is.na(values(r)) & values(r) > q] <- q

## tiles
## SystemRequirements: 
##    Python (>= 2.7), 
##    python-gdal library (For Windows, gdal installed via OSGeo4W <https://trac.osgeo.org/osgeo4w/> recommended) 
##    clipboard
## https://opensourceoptions.com/blog/how-to-install-gdal-for-python-with-pip-on-windows/
## https://gist.github.com/kelvinn/f14f0fc24445a7994368f984c3e37724?permalink_comment_id=3074415#gistcomment-3074415

library(tiler)
## https://cran.r-project.org/web/packages/tiler/vignettes/tiler-intro.html
library(raster)

## finding 1 km resolution raster files
DIR <- "/Volumes/WD 2020831 A/tmp/wbi2/"
TILE_DIR <- "_tmp/wbi-tiles/"
fl <- list.files(DIR, recursive=TRUE)
fl <- fl[endsWith(fl, "tif")]
fl <- fl[grepl("1000m", fl)]
pal <- viridis::viridis_pal(option = "D")(25)

## iterate over tif files and save TMS tiles
for (i in 1:length(fl)) {
    message(i)
    fn <- paste0(DIR, fl[i])
    tile_dir <- paste0(TILE_DIR, gsub("1000m/mean\\.tif", "tiles", fl[i]))
    tmp <- strsplit(tile_dir, "/")[[1]]
    for (j in 3:5) {
        dir.create(paste0(tmp[1:j], collapse="/"))
    }

    # r <- raster(fn)
    # plot(r, col=pal)
    # unlink(tile_dir,recursive = TRUE)
    tile(fn, tile_dir, "0-10", col = pal)
    # unlink(tile_dir,recursive = TRUE)
}

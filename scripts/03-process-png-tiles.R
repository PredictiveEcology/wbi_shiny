## color palettes: divergent for differences
neg <- colorRampPalette(colors = c("darkred", "lightgoldenrod2"))(10)
pos <- colorRampPalette(colors = c("lightgoldenrod2", "darkblue"))(10)
pal <- c(neg, pos)

## Color for sequential
pal <- viridis::viridis_pal(option = "D")(25)
plot(r, col=pal)



## some truncation as needed
q <- quantile(values(r), 0.999, na.rm=TRUE)
values(r)[!is.na(values(r)) & values(r) > q] <- q

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

fl <- list.files("/Volumes/WD 2020831 A/tmp/wbi2", recursive=TRUE)
fl <- fl[endsWith(fl, "tif")]
fl <- fl[grepl("1000m", fl)]
pal <- viridis::viridis_pal(option = "D")(25)

i <- 1
for (i in 1:length(fl)) {
    message(i)
    fn <- paste0("/Volumes/WD 2020831 A/tmp/wbi2/", fl[i])
    #tile_dir <- gsub("250m/mean\\.tif", "tiles", fn)
    tile_dir <- paste0("_tmp/wbi-tiles/", gsub("1000m/mean\\.tif", "tiles", fl[i]))
    tmp <- strsplit(tile_dir, "/")[[1]]
    for (j in 3:5) {
        #cat(paste0(tmp[1:j], collapse="/"), "\n")
        dir.create(paste0(tmp[1:j], collapse="/"))
    }

    #r <- raster(fn, col=pal)
    #unlink(tile_dir,recursive = TRUE)
    tile(fn, tile_dir, "0-10", col = pal)
    #unlink(tile_dir,recursive = TRUE)
}

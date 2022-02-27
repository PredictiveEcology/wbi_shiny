## focus on 14 species now
SPP <- c("ALFL", "AMCR", "AMRE", "AMRO", "ATSP", "BAWW", "BBWA", "BBWO", 
"BCCH", "BHCO", "BHVI", "BLPW", "BOCH", "BRBL")

## move files into temp dir
#spp <- "AMCR"
for (spp in SPP) {
    fin <- sprintf("/Volumes/WD 2020831 A/tmp/wbi/bird-%s/landr-scfm-v4/2011/250m/mean.tif",
        tolower(spp))
    fout <- sprintf("_tmp/%s-2011-mean.tif", tolower(spp))
    file.copy(fin, fout)
}

## simple plot
for (spp in SPP) {
    r <- raster(sprintf("_tmp/%s-2011-mean.tif", tolower(spp)))
    png(sprintf("_tmp/png/%s-2011-mean.png", tolower(spp)))
    plot(r)
    dev.off()
}

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

spp <- "BOCH"
tile_dir <- "_tmp/tiles"
map <- sprintf("_tmp/%s-2011-mean.tif", tolower(spp))
r <- raster(map)

pal <- colorRampPalette(c("darkblue", "lightblue"))(20)

tile(map, tile_dir, "0-10", col = pal)
#unlink(tile_dir,recursive = TRUE)

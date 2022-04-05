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

## OK - 0. decide palette
## OK - 1. extract file
## OK - 2. interpolate years for YBSA for completeness
## OK - 3. take subset (years/scenarios)
## OK - 4. record MAX values & organize in lookup table
## OK - 5. move to server (make sure space is enough <30 G)
## OK - 6. install tiler dependencies
## OK - 7. run tile creation on server

## 0. decide palette

x <- read.csv("_tmp/wbi-palette-test-responses.csv")

cat(x$Please.explain, sep="\n\n")

xx <- as.matrix(x[,3:6])
colnames(xx) <- c("viridis", "rdylbu", "spectral", "bam")
rev(colnames(xx)[order(colMeans(xx))])

table(mefa4::find_max(xx)$index)

pal <- grDevices::hcl.colors(101, "spectral", rev = TRUE)

## 1. extract file

inDir <- "/Volumes/WD 2020831 A/tmp/wbi3"
outDir <- "/Volumes/WD 2020831 A/tmp/wbi3out"
i <- "bird-ybsa"

unzip(file.path(inDir, paste0(i, ".zip")), exdir=outDir)

## 2. interpolate years for YBSA for completeness

yrs <- c(2011, 2031, 2051, 2071, 2091, 2100)

trt <- c("landr-fs-v4", "landr-fs-v6a", "landr-scfm-v4", "landr-scfm-v6a", 
"landrcs-fs-v4", "landrcs-fs-v6a", "landrcs-scfm-v4", "landrcs-scfm-v6a")

dput(list.files(file.path(outDir, "bird-ybsa")))

library(raster)
library(stars)
library(sf)
writeRasterFunction <- function(r, f) {
  s <- st_as_stars(r)
  write_stars(s, f, options = c("COMPRESS=LZW"))
}

#res <- "1000m"
#j <- trt[1]
for (res in c("1000m", "250m")) {
    for (j in trt) {

        message(res, " - ", j)

        r1 <- raster(file.path(outDir, "bird-ybsa", j, "2011", res, "mean.tif"))
        r6 <- raster(file.path(outDir, "bird-ybsa", j, "2100", res, "mean.tif"))
        v1 <- values(r1)
        v6 <- values(r6)

        r2 <- r3 <- r4 <- r5 <- r1
        w <- cumsum((yrs[2:5] - yrs[1:4]) / (2100 - 2011))
        values(r2) <- v1*(1-w[1]) + v6*w[1]
        values(r3) <- v1*(1-w[2]) + v6*w[2]
        values(r4) <- v1*(1-w[3]) + v6*w[3]
        values(r5) <- v1*(1-w[4]) + v6*w[4]

        dir.create(file.path(outDir, "bird-ybsa", j, "2031"))
        dir.create(file.path(outDir, "bird-ybsa", j, "2031", res))
        writeRasterFunction(r2, file.path(outDir, "bird-ybsa", j, "2031", res, "mean.tif"))

        dir.create(file.path(outDir, "bird-ybsa", j, "2051"))
        dir.create(file.path(outDir, "bird-ybsa", j, "2051", res))
        writeRasterFunction(r2, file.path(outDir, "bird-ybsa", j, "2051", res, "mean.tif"))

        dir.create(file.path(outDir, "bird-ybsa", j, "2071"))
        dir.create(file.path(outDir, "bird-ybsa", j, "2071", res))
        writeRasterFunction(r2, file.path(outDir, "bird-ybsa", j, "2071", res, "mean.tif"))

        dir.create(file.path(outDir, "bird-ybsa", j, "2091"))
        dir.create(file.path(outDir, "bird-ybsa", j, "2091", res))
        writeRasterFunction(r2, file.path(outDir, "bird-ybsa", j, "2091", res, "mean.tif"))

    }
}
# now zip it up ...

## 3. take subset (years/scenarios)

inDir <- "/Volumes/WD 2020831 A/tmp/wbi3"
outDir <- "/Volumes/WD 2020831 A/tmp/wbi3out"
fl <- c("bird-alfl", "bird-amcr", "bird-amre", "bird-amro", "bird-baww", 
    "bird-bbwo", "bird-bcch", "bird-bhco", "bird-bhvi", "bird-blpw", 
    "bird-boch", "bird-brbl", "bird-brcr", "bird-btnw", "bird-cawa", 
    "bird-chsp", "bird-cora", "bird-coye", "bird-deju", "bird-eaki", 
    "bird-eaph", "bird-fosp", "bird-graj", "bird-heth", "bird-hola", 
    "bird-lcsp", "bird-lefl", "bird-lisp", "bird-mawa", "bird-nofl", 
    "bird-nowa", "bird-ocwa", "bird-osfl", "bird-oven", "bird-pawa", 
    "bird-pisi", "bird-piwo", "bird-pufi", "bird-rbgr", "bird-rbnu", 
    "bird-rcki", "bird-revi", "bird-rugr", "bird-rwbl", "bird-savs", 
    "bird-sosp", "bird-swsp", "bird-swth", "bird-tewa", "bird-wavi", 
    "bird-wcsp", "bird-weta", "bird-wewp", "bird-wiwa", "bird-wiwr", 
    "bird-wtsp", "bird-wwcr", "bird-ybfl", # "bird-ybsa-incomplete", 
    "bird-ybsa", "bird-yewa", "bird-yrwa",
    "bird-atsp", "bird-bbwa", "bird-tres")

d <- expand.grid(yr=c(2011, 2100), 
    res=c("1000m", "250m"),
    sc=c("landr-scfm-v4", "landrcs-fs-v6a"))

for (i in fl) {
    message(i)
    p <- paste(i, d$sc, d$yr, d$res, "mean.tif", sep="/")
    unzip(file.path(inDir, paste0(i, ".zip")), files=p, exdir=outDir)
}

z <- read.csv("data/element-lookup.csv") 
cc <- paste0("bird-", tolower(z$species_code[z$group=="bird"]))
setdiff(cc, fl)
setdiff(fl, cc)

## copy over tree species results

for (i in z$species_code[z$group=="tree"]) {
    message(i)
    dir.create(paste0("/Volumes/WD 2020831 A/tmp/wbi3out/tree-", i))
    unique(paste0("/Volumes/WD 2020831 A/tmp/wbi3out/tree-", paste(i, d$sc, sep="/"))) |> sapply(dir.create)
    unique(paste0("/Volumes/WD 2020831 A/tmp/wbi3out/tree-", paste(i, d$sc, d$yr, sep="/"))) |> sapply(dir.create)
    unique(paste0("/Volumes/WD 2020831 A/tmp/wbi3out/tree-", paste(i, d$sc, d$yr, d$res, sep="/"))) |> sapply(dir.create)
    p <- paste(i, d$sc, d$yr, d$res, "mean.tif", sep="/")
    file.copy(
        from=paste0("/Volumes/WD 2020831 A/tmp/wbi2/tree-", p),
        to=paste0("/Volumes/WD 2020831 A/tmp/wbi3out/tree-", p))
}

## 4. record MAX values & organize in lookup table

z$i <- paste0(z$group, "-", tolower(z$species_code))
d <- expand.grid(yr=c(2011, 2100), 
    res=c("1000m", "250m"),
    sc=c("landr-scfm-v4", "landrcs-fs-v6a"))

ddd <- NULL
for (i in z$i) {
    if (!(i %in% fl)) {
    message(i)
    dd <- d
    dd$i <- i
    dd$p <- paste(i, d$sc, d$yr, d$res, "mean.tif", sep="/")
    dd$mean <- NA_real_
    dd$max <- NA_real_
    for (j in seq_along(dd$p)) {
        r <- raster(file.path("/Volumes/WD 2020831 A/tmp/wbi3out", p[j]))
        dd$mean[j] <- mean(values(r), na.rm=TRUE)
        dd$max[j] <- max(values(r), na.rm=TRUE)
    }
    ddd <- rbind(ddd, dd)
    }
}

ddd <- data.frame(ddd, z[match(ddd$i, z$i),])
ddd$i.1 <- NULL

colnames(ddd) <- c("year", "resolution", "scenario", "element_name", 
    "path", "mean", "max", "group", "species_code", 
    "common_name", "scientific_name")

ddd$pal_max <- NA_real_


ddd <- read.csv("data/element-stats.csv")
for (el in ddd$element_name) {
    message(el)
    fl <- ddd$path[ddd$element_name == el & ddd$resolution == "1000m"]
    mx <- numeric(4)
    names(mx) <- fl
    for (k in 1:4) {
        mx[k] <- ddd[ddd$path == names(mx)[k], "max"]
    }
    MX <- round(100 * mx / max(mx))
    for (k in 1:4) {
        ddd[ddd$path == names(mx)[k], "pal_max"] <- MX[k]
    }
}
summary(ddd$pal_max)

table(ddd$resolution,is.na(ddd$pal_max))

write.csv(ddd, row.names=FALSE, file="data/element-stats.csv")

## 6. install tiler dependencies


# sudo add-apt-repository ppa:ubuntugis/ppa && sudo apt-get update
# sudo apt-get update
# sudo apt-get install gdal-bin
# sudo apt-get install libgdal-dev
# export CPLUS_INCLUDE_PATH=/usr/include/gdal
# export C_INCLUDE_PATH=/usr/include/gdal
# apt install python3-pip
# pip install GDAL
# sudo apt install python-is-python3
# sudo apt install gdal-bin python3-gdal python3-gdal
# apt install r-base-core r-base-dev
# apt install r-cran-rgdal r-cran-raster r-cran-png
# R -q -e 'install.packages("tiler")'

## test that it works
library(tiler)
x <- system.file("maps/map_wgs84.tif", package = "tiler")
tile(x, "xxx", 2)


## 7. run tile creation on server with adjusted palette

library(tiler)
library(raster)

## finding 1 km resolution raster files
pal <- grDevices::hcl.colors(101, "spectral", rev = TRUE)
s <- read.csv("data/element-stats.csv")

DIR <- "tmp"

EL <- as.character(unique(s$element_name))
for (el in EL) {
    message("------------------ ", el, " ----------------")
    fl <- list.files(file.path(DIR, el), recursive=TRUE)
    fl <- fl[endsWith(fl, "tif")]
    fl <- fl[grepl("1000m", fl)]

    for (k in 1:4) {
        q <- paste0(el, "/", fl[k])
        tile_dir <- file.path(DIR, gsub("1000m/mean\\.tif", "tiles", q))
        message(k, " - ", el, " - ", Sys.time(), " - ", tile_dir)
        if (dir.exists(tile_dir))
            unlink(tile_dir, TRUE)
        dir.create(tile_dir)
        Mx <- s[s$path == q, "pal_max"]
        tile(file.path(DIR, q), 
            tile_dir, "0-10", col = pal[1:Mx])
    }
}


## 8. finalize dir structure & check results

# cp -a /root/tmp/. /root/content/api/v1/public/wbi-nwt/elements/

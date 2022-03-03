## create metadata for the file server

# DIR <- "/Volumes/WD 2020831 A/tmp/wbi2/"
# dput(list.files(DIR))

elements <- c("bird-alfl", "bird-amcr", "bird-amre", "bird-amro", "bird-atsp", 
    "bird-baww", "bird-bbwa", "bird-bbwo", "bird-bcch", "bird-bhco", 
    "bird-bhvi", "bird-blpw", "bird-boch", "bird-brbl", "tree-betu-pap", 
    "tree-lari-lar", "tree-pice-gla", "tree-pice-mar", "tree-pinu-ban", 
    "tree-popu-tre")

d <- expand.grid(
    kind = "elements",
    group = "bird",
    element = elements,
    scenario = c("landr-scfm-v4", "landrcs-fs-v6a"),
    period = c("2011", "2100"),
    resolution = c("250m", "1000m", "tiles"),
    file = "mean.tif",
    stringsAsFactors = FALSE
)
d$group[startsWith(d$element, "tree")] <- "tree"
d$file[d$resolution == "tiles"] <- "{z}/{x}/{y}.png"

d$path <- with(d, paste("api/v1/public/wbi-nwt/elements",
    element, scenario, period, resolution, file, sep="/"))

d[d$element=="bird-alfl",]

# ROOT <- "https://wbi-nwt.analythium.app"
# URL <- paste0(ROOT, "/", d$path[1])
#
# library(raster)
# plot(raster(URL))
# you can also use download.file(URL)

library(jsonlite)

writeLines(toJSON(d, pretty=FALSE), "scripts/index.json")

## This file will be at `content/api/v1/public/wbi-nwt/elements/index.json`

URL <- "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/index.json"

d <- fromJSON(URL)
str(d)

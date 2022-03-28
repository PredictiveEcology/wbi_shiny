## create metadata for the file server

# DIR <- "/Volumes/WD 2020831 A/tmp/wbi2/"
# dput(list.files(DIR))

#elements <- list.files("/Volumes/WD 2020831 A/tmp/wbi3out")
elements <- c("bird-alfl", "bird-amcr", "bird-amre", "bird-amro", "bird-atsp", 
    "bird-baww", "bird-bbwa", "bird-bbwo", "bird-bcch", "bird-bhco", 
    "bird-bhvi", "bird-blpw", "bird-boch", "bird-brbl", "bird-brcr", 
    "bird-btnw", "bird-cawa", "bird-chsp", "bird-cora", "bird-coye", 
    "bird-deju", "bird-eaki", "bird-eaph", "bird-fosp", "bird-graj", 
    "bird-heth", "bird-hola", "bird-lcsp", "bird-lefl", "bird-lisp", 
    "bird-mawa", "bird-nofl", "bird-nowa", "bird-ocwa", "bird-osfl", 
    "bird-oven", "bird-pawa", "bird-pisi", "bird-piwo", "bird-pufi", 
    "bird-rbgr", "bird-rbnu", "bird-rcki", "bird-revi", "bird-rugr", 
    "bird-rwbl", "bird-savs", "bird-sosp", "bird-swsp", "bird-swth", 
    "bird-tewa", "bird-tres", "bird-wavi", "bird-wcsp", "bird-weta", 
    "bird-wewp", "bird-wiwa", "bird-wiwr", "bird-wtsp", "bird-wwcr", 
    "bird-ybfl", "bird-ybsa", "bird-yewa", "bird-yrwa", "tree-betu-pap", 
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
write.csv(d, row.names=FALSE, file="scripts/api-index.csv")

## This file will be at `content/api/v1/public/wbi-nwt/elements/index.json`

URL <- "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/index.json"

d <- fromJSON(URL)
str(d)

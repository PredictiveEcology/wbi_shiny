library(shiny)
#library(shinythemes)
library(leaflet)
library(reactable)
library(sf)

BASEURL <- "https://wbi-nwt.analythium.app/api/v1/public"
ELEMENTS <- read.csv("../data/element-lookup.csv")
rownames(ELEMENTS) <- paste0(ELEMENTS$group, "-", tolower(ELEMENTS$species_code))
LINKS <- jsonlite::fromJSON(
    "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/index.json")
SCENARIOS <- list(
    "LandR SCFM V4"="landr-scfm-v4",
    "LandR.CS FS V6a"="landrcs-fs-v6a")
ELEMENT_NAMES <- paste0(ELEMENTS$group, "-", tolower(ELEMENTS$species_code))
names(ELEMENT_NAMES) <- ELEMENTS$common_name

x <- data.frame(
    LINKS[, -1],
    ELEMENTS[match(LINKS$element, rownames(ELEMENTS)), -1])
x <- x[x$resolution != "tiles",c("group", "species_code", "common_name", "scientific_name", 
    "scenario", "period", "resolution", "path")]

a <- st_read("data/regions/nwt-bcr6.gpkg")
p <- st_read("data/regions/regions.gpkg")
a$classification <- "StudyArea"
a$region <- "NWT"
a$area <- st_area(a)
p <- rbind(a[,colnames(p)], p)

source("functions.R")

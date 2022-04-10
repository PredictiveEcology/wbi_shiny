## code to prepare `data` dataset goes here

ELEMENTS <- read.csv("data-raw/element-lookup.csv")
rownames(ELEMENTS) <- paste0(ELEMENTS$group, "-", tolower(ELEMENTS$species_code))

# TODO // Peter adding 2 more columns, one is the max value, and the second is 
# the max index value for the hex code to drive the color scaling... need to add
# this data to the mapping functions `max` arguments in the legend functions
LINKS <- jsonlite::fromJSON(
  "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/index.json"
)

MAPSTATS <- read.csv("data-raw/element-stats.csv")
MAPSTATS <- MAPSTATS[MAPSTATS$resolution == "1000m", 
  c("element_name", "year", "scenario", "max", "pal_max")]

SCENARIOS <- list(
  "LandR SCFM V4" = "landr-scfm-v4",
  "LandR.CS FS V6a" = "landrcs-fs-v6a"
)

ELEMENT_NAMES <- paste0(ELEMENTS$group, "-", tolower(ELEMENTS$species_code))
names(ELEMENT_NAMES) <- ELEMENTS$common_name

MAIN <- data.frame(
  LINKS[, -1],
  ELEMENTS[match(LINKS$element, rownames(ELEMENTS)), -1]
)

cols <- c("group", "species_code", "common_name", "scientific_name", 
          "scenario", "period", "resolution", "path")

MAIN <- MAIN[MAIN$resolution != "tiles", cols]

STATS <- readRDS("data-raw/elements-regions-stats-250m.rds")

usethis::use_data(
  ELEMENTS, LINKS, SCENARIOS, MAIN, STATS, MAPSTATS,
  overwrite = TRUE
)

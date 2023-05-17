## code to prepare `data` dataset goes here

# ELEMENTS ----
ELEMENTS <- read.csv("data-raw/element-lookup.csv")
rownames(ELEMENTS) <- paste0(ELEMENTS$group, "-", tolower(ELEMENTS$species_code))

# ELEMENT_NAMES ----
ELEMENT_NAMES <- tolower(ELEMENTS$species_code)
names(ELEMENT_NAMES) <- ELEMENTS$common_name

ELEMENT_NAMES <- list(
  bird = ELEMENT_NAMES[ELEMENTS$group == "bird"],
  tree = ELEMENT_NAMES[ELEMENTS$group == "tree"]
)

# TODO // Peter adding 2 more columns, one is the max value, and the second is 
# the max index value for the hex code to drive the color scaling... need to add
# this data to the mapping functions `max` arguments in the legend functions
LINKS <- jsonlite::fromJSON(
  "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/index.json"
)

# MAPSTATS ----
# Retrieve .rds file containing MAPSTATS data from API
MAPSTATS <- paste0(
  get_golem_config("app_baseurl"),
  "api/v1/public/wbi/maps-lonlat-with-stats.rds"
) |> 
  url() |> 
  readRDS()

# Keep only the columns needed for legend gradients
MAPSTATS$max <- MAPSTATS$q1
MAPSTATS <- MAPSTATS[, c("region", "element", "scenario", "period", "max")]

# SCENARIOS ----
SCENARIOS <- list(
  "CNRM-ESM2-1 SSP370" = "cnrm-esm2-1-ssp370", 
  "CanESM5 SSP370" = "canesm5-ssp370", 
  "CNRM-ESM2-1 SSP585" = "cnrm-esm2-1-ssp585", 
  "CanESM5 SSP585" = "canesm5-ssp585"
)


MAIN <- data.frame(
  LINKS[, -1],
  ELEMENTS[match(LINKS$element, rownames(ELEMENTS)), -1]
)

cols <- c("group", "species_code", "common_name", "scientific_name", 
          "scenario", "period", "resolution", "path")

MAIN <- MAIN[MAIN$resolution != "tiles", cols]

STATS <- readRDS("data-raw/elements-regions-stats-250m.rds")

i <- which(rownames(STATS$regions) == "Caribou Meta-herds: Decho South")
rownames(STATS$regions)[i] <- "Caribou Meta-herds: Dehcho South"
STATS$regions$region[i] <- "Dehcho South"
dimnames(STATS$statistics)[[2]][i] <- "Caribou Meta-herds: Dehcho South"

i <- which(rownames(STATS$regions) == "Caribou Meta-herds: Decho North")
rownames(STATS$regions)[i] <- "Caribou Meta-herds: Dehcho North"
STATS$regions$region[i] <- "Dehcho North"
dimnames(STATS$statistics)[[2]][i] <- "Caribou Meta-herds: Dehcho North"

i <- which(rownames(STATS$regions) == "Caribou Meta-herds: Hay River")
rownames(STATS$regions)[i] <- "Caribou Meta-herds: Hay River Lowlands"
STATS$regions$region[i] <- "Hay River Lowlands"
dimnames(STATS$statistics)[[2]][i] <- "Caribou Meta-herds: Hay River Lowlands"

CARIBOU <- read.csv("data-raw/caribou-lambda.csv")
CARIBOU$region <- paste("Caribou Meta-herds:", CARIBOU$region)

usethis::use_data(
  ELEMENTS, LINKS, SCENARIOS, MAIN, STATS, MAPSTATS, ELEMENT_NAMES,
  CARIBOU,
  overwrite = TRUE
)

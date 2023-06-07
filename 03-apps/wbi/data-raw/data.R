## code to prepare `data` dataset goes here

# ELEMENTS ----
ELEMENTS <- read.csv("data-raw/element-lookup.csv")
rownames(ELEMENTS) <- ELEMENTS$species_code

# ELEMENT_NAMES ----
ELEMENT_NAMES <- split(ELEMENTS$species_code, ELEMENTS$group)
ELEMENT_NAMES <- mapply(
  FUN = function(x, y) setNames(x, y), 
  x = ELEMENT_NAMES, 
  y = split(ELEMENTS$common_name, ELEMENTS$group)
)

# MAPSTATS ----
# Retrieve .rds file containing MAPSTATS data from API
ALLMAPS <- paste0(
  get_golem_config("app_baseurl"),
  "api/v1/public/wbi/links-and-stats.rds"
) |> 
  url() |> 
  readRDS()

# Keep only the columns needed for legend gradients
MAPSTATS <- ALLMAPS[ALLMAPS$resolution=="lonlat",]
MAPSTATS$min <- MAPSTATS$q0
MAPSTATS$max <- MAPSTATS$q1
MAPSTATS <- MAPSTATS[, c("region", "element", "scenario", "period", "min", "max")]

# SCENARIOS ----
SCENARIOS <- list(
  "CNRM-ESM2-1 SSP370" = "cnrm-esm2-1-ssp370", 
  "CanESM5 SSP370" = "canesm5-ssp370", 
  "CNRM-ESM2-1 SSP585" = "cnrm-esm2-1-ssp585", 
  "CanESM5 SSP585" = "canesm5-ssp585"
)

REGIONS <- list(
  `Full Extent` = "full-extent", 
  Alberta = "ab", 
  `British Columbia` = "bc", 
  Manitoba = "mb", 
  `Northwest Territories` = "nt", 
  Saskatchewan = "sk", 
  `Yukon Territory` = "yt")

# Regional summaries
STATS <- readRDS("data-raw/elements-regions-stats-1000m.rds")

usethis::use_data(
  ELEMENTS, SCENARIOS, MAPSTATS, ELEMENT_NAMES, ALLMAPS, REGIONS,
  STATS, 
  overwrite = TRUE
)

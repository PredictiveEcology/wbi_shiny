## code to prepare `data` dataset goes here

BASEURL <- "https://wbi-nwt.analythium.app/api/v1/public"

ELEMENTS <- read.csv("element-lookup.csv")
rownames(ELEMENTS) <- paste0(ELEMENTS$group, "-", tolower(ELEMENTS$species_code))

LINKS <- jsonlite::fromJSON(
  "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/index.json"
)

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

usethis::use_data(
  ELEMENTS, LINKS, SCENARIOS, MAIN, 
  overwrite = TRUE
)

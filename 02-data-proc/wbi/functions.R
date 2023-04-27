library(terra)
library(stars)

ROOT <- "/mnt/volume_tor1_01/wbi/outputs2"
OUT1 <- "/mnt/volume_tor1_01/wbi/mid"
OUT2 <- "/mnt/volume_tor1_01/wbi/final"

make_dir <- function(dir, ...) {
  if (!dir.exists(dir))
    dir.create(dir, recursive = TRUE)
  invisible(NULL)
}
move_file <- function(from, to, ...) {
  dir <- dirname(to)
  if (!dir.exists(dir))
    dir.create(dir, recursive = TRUE)
  file.copy(from, to, ...)
  invisible(NULL)
}
make_name <- function(
    root=".",
    api_ver="api/v1",
    access="public",
    project="wbi",
    region,
    kind="elements",
    element,
    scenario,
    period,
    resolution,
    file) {
  paste(
    root,
    api_ver,
    access,
    project,
    region,
    kind,
    element,
    scenario,
    period,
    resolution,
    file,
    sep="/")
}
make_name_from_list <- function(x, root = ".") {
  make_name(
    root=root,
    api_ver=x$api_ver,
    access=x$access,
    project=x$project,
    region=x$region,
    kind=x$kind,
    element=x$element,
    scenario=x$scenario,
    period=x$period,
    resolution=x$resolution,
    file=x$file)
}

parse_path <- function(p) {
  pl <- strsplit(p, "/")
  data.frame(
    # path = p,
    api_ver = sapply(pl, \(x) paste0(x[1], "/", x[2])),
    access = sapply(pl, \(x) x[3]),
    project = sapply(pl, \(x) x[4]),
    region = sapply(pl, \(x) x[5]),
    kind = sapply(pl, \(x) x[6]),
    element = sapply(pl, \(x) x[7]),
    scenario = sapply(pl, \(x) x[8]),
    period = sapply(pl, \(x) x[9]),
    resolution = sapply(pl, \(x) x[10]),
    file = sapply(pl, \(x) x[11]))
}
rast_stats <- function(r) {
  if (is.character(r))
    r <- terra::rast(r)
  v <- na.omit(values(r))
  q <- quantile(v, c(0, 0.5, 0.99, 0.999, 1))
  names(q) <- paste0("q", c(0, 50, 99, 999, 1))
  c(mean=mean(v), q)
}
rast_stats2 <- function(r) {
  if (is.character(r))
    r <- stars::read_stars(r)
  v <- na.omit(as.numeric(r[[1]]))
  q <- quantile(v, c(0, 0.5, 0.99, 0.999, 1))
  names(q) <- paste0("q", c(0, 50, 99, 999, 1))
  c(mean=mean(v), q)
}

JURS <- c("AB", "BC", "MB", "NT", "SK", "YT")
names(JURS) <- tolower(JURS)

SCENS <- c(
  "cnrm-esm2-1-ssp370"="CNRM-ESM2-1_SSP370", 
  "canesm5-ssp370"="CanESM5_SSP370", 
  "cnrm-esm2-1-ssp585"="CNRM-ESM2-1_SSP585", 
  "canesm5-ssp585"="CanESM5_SSP585")

YRS20 <- c(2011, 2031, 2051, 2071, 2091)
YRS10 <- c(2011, 2021, 2031, 2041, 2051, 2061, 2071, 2081, 2091, 2100)

Values <- list(
  region = list(
    "Alberta" = "ab",
    "British Columbia" = "bc", 
    "Manitoba" = "mb", 
    "Northwest Territories" = "nt", 
    "Saskatchewan" = "sk", 
    "Yukon Territory" = "yt"),
  scenario <- list(
    "CNRM-ESM2-1 SSP370" = "cnrm-esm2-1-ssp370", 
    "CanESM5 SSP370" = "canesm5-ssp370", 
    "CNRM-ESM2-1 SSP585" = "cnrm-esm2-1-ssp585", 
    "CanESM5 SSP585" = "canesm5-ssp585"),
  year20 = c(2011, 2031, 2051, 2071, 2091),
  year10 = c(2011, 2021, 2031, 2041, 2051, 2061, 2071, 2081, 2091, 2100))




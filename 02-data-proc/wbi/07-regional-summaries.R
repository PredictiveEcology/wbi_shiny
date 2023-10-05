## load libraries
library(sf)
library(terra)
library(mefa4)
library(dplyr)

## read in example rasters
JURS <- c("AB", "BC", "MB", "NT", "SK", "YT")
r <- lapply(tolower(JURS), \(x) {
    rast(
        sprintf(
            "https://wbi.predictiveecology.org/api/v1/public/wbi/%s/elements/biomass/canesm5-ssp370/2011/250m/mean.tif",
            x))
})

## read in the shapefiles/geopackages that define the boundaries for regional classifications
## here as an example, we define BCR/jurisdiction units

## BCRs
f <- "02-data-proc/wbi_nwt/boundaries/bcr_terrestrial_shape/BCR_Terrestrial_master_International.shp"
st_layers(f)
z <- st_read(f)
z <- st_transform(z, st_crs(r[[1]]))
z <- z[z$BCR %in% c(4, 6, 7, 8), ]

## Canada jurisdictions
## from https://ftp.maps.canada.ca/pub/nrcan_rncan/vector/canvec/shp/Admin/canvec_15M_CA_Admin_shp.zip
f2 <- "02-data-proc/wbi/boundaries/canvec_15M_CA_Admin/geo_political_region_2.shp"
p <- st_read(f2)
p <- p[p$juri_en %in% c("Alberta", "British Columbia", "Manitoba", "Northwest Territories", "Nunavut", "Saskatchewan", "Yukon"),]
p <- st_transform(p, st_crs(r[[1]]))

## intersect BCRs and jurisdictions
zp <- st_intersection(z[,c("BCR", "LABEL")], p[,c("juri_en", "juri_fr")])
table(zp$juri_en, zp$BCR)
zp$area <- as.numeric(st_area(zp)) / 10^6
zp <- zp[!(zp$juri_en=="Nunavut" & zp$area < 5000),]

zp$rast_value <- seq_len(nrow(zp))
zp$bcr_juri <- paste0("BCR ", zp$BCR, " - ", zp$juri_en)

## check that things alight well: full extent map with polygons overlaid
rf <- rast("https://wbi.predictiveecology.org/api/v1/public/wbi/full-extent/elements/biomass/canesm5-ssp370/2011/1000m/mean.tif")
plot(rf)
plot(zp$geom, add=T)

## classify the raser pixels by the polygon IDs
rrf <- rf
v <- values(rf)[,1]
df <- data.frame(index=1:length(v), value=ifelse(is.na(v), NA, 1))
for (j in seq_len(nrow(zp))) {
    message(j)
    m <- mask(rf, zp[j,])
    vj <- !is.na(values(m)[,1])
    df$value[vj] <- j
}
values(rrf) <- df$value

## load the lookup table for all the species/periods/scenarios for full extent maps
u <- "https://wbi.predictiveecology.org/api/v1/public/wbi/links-and-stats.rds"
m <- readRDS(url(u))
m <- m[m$resolution == "1000m" & m$region == "full-extent",]

## calculate number of pixel and sum of pixel values
Npix <- table(df$value)
SUMS <- matrix(0, nrow(m), nrow(zp))
dimnames(SUMS) <- list(m$link, names(Npix))
NPIX <- matrix(as.numeric(Npix), nrow(m), nrow(zp), byrow = TRUE)
dimnames(NPIX) <- list(m$link, names(Npix))

## we loop through the species/periods/scenarios

# i <- 1
ss <- 1:nrow(m)
# ss <- which(rowSums(is.na(SUMS)) > 0)
for (i in ss) {

    message(which(ss == i), " / ", length(ss))
    u2 <- paste0("https://wbi.predictiveecology.org/", m$link[i])
    r2 <- rast(u2)
    v2 <- values(r2)[,1]
    sb <- sum_by(v2[!is.na(v2)], df$value[!is.na(v2)])
    sb <- sb[match(names(Npix),rownames(sb)),]
    SUMS[i,] <- sb[,1]
    if (any(is.na(v2))) {
        NPIX[i,] <- sb[,2]
    }
}
sum(is.na(SUMS))
sum(is.na(NPIX))
table(rowSums(is.na(SUMS)))
saveRDS(list(SUMS=SUMS, NPIX=NPIX), "02-data-proc/wbi/sums-by-bcr-juri.rds")

o00 <- readRDS("02-data-proc/wbi/sums-by-bcr-juri.rds")
SUMS <- o00$SUMS
NPIX <- o00$NPIX

## Calculate combined statistics for BCR and Juri

## All pixels in WBI
SUMSwbi <- rowSums(SUMS)
NPIXwbi <- rowSums(NPIX)
MEANwbi <- SUMSwbi / NPIXwbi

## group sums into BCR and JURS units
## calculate means
colnames(SUMS) <- zp$bcr_juri
colnames(NPIX) <- zp$bcr_juri
MEAN <- SUMS / NPIX

SUMSbcr <- groupSums(SUMS, 2, paste("BCR", zp$BCR))
NPIXbcr <- groupSums(NPIX, 2, paste("BCR", zp$BCR))
MEANbcr <- SUMSbcr / NPIXbcr

SUMSjuri <- groupSums(SUMS, 2, zp$juri_en)
NPIXjuri <- groupSums(NPIX, 2, zp$juri_en)
MEANjuri <- SUMSjuri / NPIXjuri


## Combine into 1 simplified sf df:
## - BCR
## - Juri
## - BCR/Juri
## Save a simplified geometry for plotting
zp <- st_cast(zp, "MULTIPOLYGON")

zp$all <- "WBI: Western Boreal Initiative"
zp0 <- zp |> group_by(all) |> summarize() |> st_cast("MULTIPOLYGON")
zp1 <- zp |> group_by(BCR) |> summarize() |> st_cast("MULTIPOLYGON")
zp2 <- zp |> group_by(juri_en) |> summarize() |> st_cast("MULTIPOLYGON")
class(zp0) <- class(zp1) <- class(zp2) <- class(zp)

zp0$classification <- "WBI"
zp0$region <- "WBI: Western Boreal Initiative"
zp0$area <- as.numeric(st_area(zp0)) / 10^6

zp1$classification <- "BCR"
zp1$region <- paste("BCR", zp1$BCR)
zp1$area <- as.numeric(st_area(zp1)) / 10^6

zp2$classification <- "Jurisdiction"
zp2$region <- zp2$juri_en
zp2$area <- as.numeric(st_area(zp2)) / 10^6


zp$region <- zp$bcr_juri
zp$classification <- "BCR / Jurisdiction"

pp <- rbind(
    zp0[,c("classification", "region", "area")],
    zp1[,c("classification", "region", "area")],
    zp2[,c("classification", "region", "area")],
    zp[,c("classification", "region", "area")])
rownames(pp) <- NULL

pps <- st_simplify(pp, dTolerance = 1000)
rownames(pps) <- pps$region
pps <- st_cast(pps, "MULTIPOLYGON")
saveRDS(pps, "02-data-proc/wbi/boundaries/regions.rds")

## Organize the output object for the app

rownames(m) <- m$link
Stats <- cbind("WBI: Western Boreal Initiative"=MEANwbi, MEANbcr, MEANjuri, MEAN)
nStats <- cbind("WBI: Western Boreal Initiative"=NPIXwbi, NPIXbcr, NPIXjuri, NPIX)
storage.mode(nStats) <- "integer"

ers <- list(elements = m,
    regions = pps,
    statistics = list(
        mean = Stats[rownames(m), rownames(pps)], 
        npix = nStats[rownames(m), rownames(pps)]))
saveRDS(ers, "03-apps/wbi/data-raw/elements-regions-stats-1000m.rds")

## Check saved results

ers <- readRDS("03-apps/wbi/data-raw/elements-regions-stats-1000m.rds")

x <- data.frame(ers$elements, Mean=ers$statistics$mean[,1])
x$year <- as.integer(x$period)
library(lme4)

CF <- list()
for (i in unique(x$element)) {
    CF[[i]] <- coef(lm(log(Mean) ~ scenario + I(year-2011), x[x$element == i,]))
}
CF <- do.call(rbind, CF)
summary(CF)
hist(CF[,5])

library(sf)
library(terra)
library(mefa4)
library(dplyr)

## example rasters
JURS <- c("AB", "BC", "MB", "NT", "SK", "YT")
r <- lapply(tolower(JURS), \(x) {
    rast(
        sprintf(
            "https://wbi.predictiveecology.org/api/v1/public/wbi/%s/elements/biomass/canesm5-ssp370/2011/250m/mean.tif",
            x))
})

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

zp <- st_intersection(z[,c("BCR", "LABEL")], p[,c("juri_en", "juri_fr")])
table(zp$juri_en, zp$BCR)
zp$area <- as.numeric(st_area(zp)) / 10^6
zp <- zp[!(zp$juri_en=="Nunavut" & zp$area < 5000),]

zp$rast_value <- seq_len(nrow(zp))
zp$bcr_juri <- paste0("BCR ", zp$BCR, " - ", zp$juri_en)


rf <- rast("https://wbi.predictiveecology.org/api/v1/public/wbi/full-extent/elements/biomass/canesm5-ssp370/2011/1000m/mean.tif")
plot(rf)
plot(zp$geom, add=T)

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

u <- "https://wbi.predictiveecology.org/api/v1/public/wbi/links-and-stats.rds"
m <- readRDS(url(u))
m <- m[m$resolution == "1000m" & m$region == "full-extent",]

# number of pixel and sum of pixel values
NPIX <- table(df$value)
SUMS <- matrix(0, nrow(m), nrow(zp))
dimnames(SUMS) <- list(m$link, names(NPIX))

# i <- 1
for (i in 1:nrow(SUMS)) {

    message(i, " / ", nrow(SUMS))
    u2 <- paste0("https://wbi.predictiveecology.org/", m$link[i])
    r2 <- rast(u2)
    v2 <- values(r2)[,1]
    sb <- sum_by(v2, df$value)
    sb <- sb[match(names(NPIX),rownames(sb)),]
    SUMS[i,] <- sb[,1]

}

# Calculate combined statistics for BCR and Juri

## group sums into BCR and JURS units
## calculate means



# Combine into 1 simplified sf df:
# - BCR
# - Juri
# - BCR/Juri
# Save a simplified geometry for plotting
zp <- st_cast(zp, "MULTIPOLYGON")

zp1 <- zp |> group_by(BCR) |> summarize() |> st_cast("MULTIPOLYGON")
zp2 <- zp |> group_by(juri_en) |> summarize() |> st_cast("MULTIPOLYGON")
class(zp1) <- class(zp2) <- class(zp)
zp1$classification <- "BCR"
zp2$classification <- "Jurisdiction"
zp1$region <- zp1$BCR
zp1$area <- as.numeric(st_area(zp1)) / 10^6
zp2$classification <- "Jurisdiction"
zp2$region <- zp2$juri_en
zp2$area <- as.numeric(st_area(zp2)) / 10^6


zp$region <- zp$bcr_juri
zp$classification <- "BCR / Jurisdiction"

pp <- rbind(zp[,c("classification", "region", "area")],
    zp1[,c("classification", "region", "area")],
    zp2[,c("classification", "region", "area")])
rownames(pp) <- NULL

pps <- st_simplify(pp, dTolerance = 1000)

saveRDS(pps, "02-data-proc/wbi/boundaries/regions.rds")

# Organize the output object for the app


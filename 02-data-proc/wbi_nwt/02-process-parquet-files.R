# SCENARIOS
#  LandR: non-climate-sensitive version of forest growth model
#  LandR.CS: climate-sensitive version of forest growth model
#  SCFM: non-climate-sensitive version of wildfire model
#  fS: climate-sensitive version of wildfire model
#  V4: non-climate-sensitive version of bird model
#  V6a: climate-sensitive version of bird model
#    i.e., Fully non-climate sensitive model: LandR_SCFM_V4
#    i.e., Fully climate sensitive model: LandR.CS_fS_V6a
# RUN: each Run (i.e., "run1") is a replicate for stochastic processes# YEAR: each Year of the simulations
# pixelID: Index to match the raster

## Use chunked parquet files
if (!require("Require")) {
  install.packages("Require")
  library("Require")
}
Require(c("arrow", "raster", "sf", "stars"))

if (grepl("for-cast[.]ca", Sys.info()[["nodename"]])) {
  options(mc.cores = 64L) ## number of bird species
  dataDir <- file.path("/mnt/wbi_data/NWT/outputs/PAPER_EffectsOfClimateChange/posthoc/summaryRasters")
  r <- raster("~/GitHub/wbi_shiny/data/raster-template-NWT.tif")
} else {
  options(mc.cores = 1L)
  dataDir <- "."
  r <- raster("wbi_shiny/scripts/raster-template-NWT.tif")
}

writeRasterFunction <- function(r, f) {
  s <- st_as_stars(r)
  write_stars(s, f, options = c("COMPRESS=LZW"))
}

## Load raster template for NWT study area
r_crs <- raster::crs(r)
r_crs
# "+proj=lcc +lat_0=0 +lon_0=-95 +lat_1=49 +lat_2=77 +x_0=0 +y_0=0 +ellps=GRS80 +units=m +no_defs"

# YEAR=2011
# RUN=1
# SCENARIO="LandR_SCFM_V4"
# SPECIES="ALFL"
tr_path <- function(RUN, SPECIES, YEAR, SCENARIO) {
  file.path(dataDir, "arrow", paste0(SPECIES, "_rastersSummaryTable"), paste0("year=", YEAR),
            paste0("run=run", RUN), "part-0.parquet")
}

SPP <- substr(list.files(file.path(dataDir, "arrow")), 1, 4)
YEARS <- c(2011, 2031, 2051, 2071, 2091, 2100)
RUNS <- 1:10
SCENARIOS <- c(land_r_f_s_v4 = "LandR_fS_V4",
               land_r_f_s_v6a = "LandR_fS_V6a",
               land_r_cs_f_s_v4 = "LandR.CS_fS_V4",
               land_r_cs_f_s_v6a = "LandR.CS_fS_V6a",
               land_r_scfm_v4 = "LandR_SCFM_V4",
               land_r_scfm_v6a = "LandR_SCFM_V6a",
               land_r_cs_scfm_v4 = "LandR.CS_SCFM_V4",
               land_r_cs_scfm_v6a = "LandR.CS_SCFM_V6a")
SAVE_SD <- FALSE

#SPECIES="ALFL"
#YEAR=2011
#SCENARIO="LandR_SCFM_V4"
parallel::mclapply(SPP, function(SPECIES) {
  for (SCENARIO in SCENARIOS) {
    id <- names(SCENARIOS[SCENARIOS == SCENARIO])
    id_dir <- gsub("\\.", "", gsub("_", "-", tolower(SCENARIO)))

    for (YEAR in YEARS) {
      fl <- tr_path(RUNS, SPECIES, YEAR, SCENARIO)
      for (i in seq_along(fl)) {
        message(SPECIES, " ", SCENARIO, " ", YEAR, " ", i)
        d <- open_dataset(fl[i])
        if (i == 1) {
          v0 <- as.data.frame(d[,c("pixel_id", id)])
          colnames(v0)[2] <- "run1"
        } else {
          v <- as.data.frame(d[,c("pixel_id", id)])
          v <- v[match(v0$pixel_id, v$pixel_id),]
          stopifnot(all(v0$pixel_id == v$pixel_id))
          v0[[paste0("run", i)]] <- v[[2]]
        }
      }
      message("calculating stats")
      Mean <- rowMeans(v0[, -1])
      rMean <- r
      values(rMean)[v0$pixel_id] <- Mean

      meanRstDir <- checkPath(file.path(dataDir, "tiff_output", paste0("bird-", tolower(SPECIES)),
                                        id_dir, YEAR, "250m"), create = TRUE)
      writeRasterFunction(rMean, file.path(meanRstDir, "mean.tif"))

      ## aggregate to 1km^2: aggregation function is the mean
      ## goes from 26M to 2M per file
      rMean2 <- aggregate(rMean, c(4, 4))

      meanRstDir2 <- checkPath(file.path(dataDir, "tiff_output", paste0("bird-", tolower(SPECIES)),
                                         id_dir, YEAR, "1000m"), create = TRUE)
      writeRasterFunction(rMean2, file.path(meanRstDir2, "mean.tif"))

      if (SAVE_SD) {
        SD <- apply(v0[,-1], 1, sd)
        rSD <- r
        values(rSD)[v0$pixel_id] <- SD
        rSD2 <- aggregate(rMean, c(4, 4))
        writeRasterFunction(rSD, file.path(meanRstDir, "stdev.tif"))
        writeRasterFunction(rSD2, file.path(meanRstDir2, "stdev.tif"))
      }
    }
  }
})



## Use 2 scenarios
## Non-climate-sensitive (LandR_SCFM + Birds V4) LandR_SCFM_V4
## Climate-sensitive (LandR.CS_fS + Birds CC) LandR.CS_fS_V6a

## Use 2 time periods: 2011, 2100

SPP <- c("ALFL", "AMCR", "AMRE", "AMRO", "ATSP", "BAWW", "BBWA", "BBWO",
         "BCCH", "BHCO", "BHVI", "BLPW", "BOCH", "BRBL")

# 250 m
for (spp in SPP) {
    message(spp)

    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/2011/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/2011/250m", tolower(spp)))
    fin <- sprintf("/Volumes/WD 2020831 A/tmp/wbi/bird-%s/landr-scfm-v4/2011/250m/mean.tif", tolower(spp))
    fout <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/2011/250m/mean.tif", tolower(spp))
    file.copy(fin, fout)

    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/2100/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/2100/250m", tolower(spp)))
    fin <- sprintf("/Volumes/WD 2020831 A/tmp/wbi/bird-%s/landr-scfm-v4/2100/250m/mean.tif", tolower(spp))
    fout <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/2100/250m/mean.tif", tolower(spp))
    file.copy(fin, fout)

    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/2011/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/2011/250m", tolower(spp)))
    fin <- sprintf("/Volumes/WD 2020831 A/tmp/wbi/bird-%s/landrcs-fs-v6a/2011/250m/mean.tif", tolower(spp))
    fout <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/2011/250m/mean.tif", tolower(spp))
    file.copy(fin, fout)

    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/2100/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/2100/250m", tolower(spp)))
    fin <- sprintf("/Volumes/WD 2020831 A/tmp/wbi/bird-%s/landrcs-fs-v6a/2100/250m/mean.tif", tolower(spp))
    fout <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/2100/250m/mean.tif", tolower(spp))
    file.copy(fin, fout)

}

# 1 km
for (spp in SPP) {
    message(spp)

    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/2011/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/2011/1000m", tolower(spp)))
    fin <- sprintf("/Volumes/WD 2020831 A/tmp/wbi/bird-%s/landr-scfm-v4/2011/1000m/mean.tif", tolower(spp))
    fout <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/2011/1000m/mean.tif", tolower(spp))
    file.copy(fin, fout)

    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/2100/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/2100/1000m", tolower(spp)))
    fin <- sprintf("/Volumes/WD 2020831 A/tmp/wbi/bird-%s/landr-scfm-v4/2100/1000m/mean.tif", tolower(spp))
    fout <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landr-scfm-v4/2100/1000m/mean.tif", tolower(spp))
    file.copy(fin, fout)

    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/2011/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/2011/1000m", tolower(spp)))
    fin <- sprintf("/Volumes/WD 2020831 A/tmp/wbi/bird-%s/landrcs-fs-v6a/2011/1000m/mean.tif", tolower(spp))
    fout <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/2011/1000m/mean.tif", tolower(spp))
    file.copy(fin, fout)

    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/2100/", tolower(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/2100/1000m", tolower(spp)))
    fin <- sprintf("/Volumes/WD 2020831 A/tmp/wbi/bird-%s/landrcs-fs-v6a/2100/1000m/mean.tif", tolower(spp))
    fout <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/bird-%s/landrcs-fs-v6a/2100/1000m/mean.tif", tolower(spp))
    file.copy(fin, fout)

}



SPP <- c("Betu_Pap", "Lari_Lar", "Pice_Gla", "Pice_Mar", "Pinu_Ban", "Popu_Tre")
f <- function(x) tolower(gsub("_", "-", x))
for (spp in SPP) {
    message(spp)
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/", f(spp)))

    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/", f(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/2011/", f(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/2011/250m", f(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/2100/", f(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/2100/250m", f(spp)))

    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/", f(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/2011/", f(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/2011/250m", f(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/2100/", f(spp)))
    dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/2100/250m", f(spp)))

  fin <-  sprintf("/Volumes/WD 2020831 A/tmp/wbi/vegetationResults/averageBiomass_LandR.CS_fS_2011_%s.tif", spp)
  fout <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/2011/250m/mean.tif", f(spp))
    file.copy(fin, fout)

  fin <-  sprintf("/Volumes/WD 2020831 A/tmp/wbi/vegetationResults/averageBiomass_LandR.CS_fS_2100_%s.tif", spp)
  fout <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/2100/250m/mean.tif", f(spp))
    file.copy(fin, fout)

  fin <-  sprintf("/Volumes/WD 2020831 A/tmp/wbi/vegetationResults/averageBiomass_LandR_SCFM_2011_%s.tif", spp)
  fout <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/2011/250m/mean.tif", f(spp))
    file.copy(fin, fout)

  fin <-  sprintf("/Volumes/WD 2020831 A/tmp/wbi/vegetationResults/averageBiomass_LandR_SCFM_2100_%s.tif", spp)
  fout <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/2100/250m/mean.tif", f(spp))
    file.copy(fin, fout)
}

for (spp in SPP) {
    message(spp)

  fr <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/2011/250m/mean.tif", f(spp))
  rMean <- raster(fr)
  rMean2 <- aggregate(rMean, c(4, 4))
  dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/2011/1000m", f(spp)))
  writeRasterFunction(rMean2, sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/2011/1000m/mean.tif", f(spp)), overwrite=TRUE)

  fr <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/2100/250m/mean.tif", f(spp))
  rMean <- raster(fr)
  rMean2 <- aggregate(rMean, c(4, 4))
  dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/2100/1000m", f(spp)))
  writeRasterFunction(rMean2, sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landrcs-fs-v6a/2100/1000m/mean.tif", f(spp)), overwrite=TRUE)

  fr <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/2011/250m/mean.tif", f(spp))
  rMean <- raster(fr)
  rMean2 <- aggregate(rMean, c(4, 4))
  dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/2011/1000m", f(spp)))
  writeRasterFunction(rMean2, sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/2011/1000m/mean.tif", f(spp)), overwrite=TRUE)

  fr <- sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/2100/250m/mean.tif", f(spp))
  rMean <- raster(fr)
  rMean2 <- aggregate(rMean, c(4, 4))
  dir.create(sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/2100/1000m", f(spp)))
  writeRasterFunction(rMean2, sprintf("/Volumes/WD 2020831 A/tmp/wbi2/tree-%s/landr-scfm-v4/2100/1000m/mean.tif", f(spp)), overwrite=TRUE)

}

# Classes ‘data.table’ and 'data.frame':	381193620 obs. of  12 variables:
#  $ LandR_fS_V4      : num  0.181 0.18 0.196 0.253 0.184 ...
#  $ location         : num  2 2 2 2 2 2 2 2 2 NA ...
#  $ pixelID          : int  38546 38547 38548 38549 41470 41471 41472 41473 41474 41475 ...
#  $ Run              : chr  "run1" "run1" "run1" "run1" ...
#  $ Year             : num  2011 2011 2011 2011 2011 ...
#  $ LandR_fS_V6a     : num  0.143 0.143 0.144 0.171 0.143 ...
#  $ LandR.CS_fS_V4   : num  0.181 0.18 0.196 0.253 0.184 ...
#  $ LandR.CS_fS_V6a  : num  0.143 0.143 0.144 0.171 0.143 ...
#  $ LandR_SCFM_V4    : num  0.171 0.171 0.196 0.238 0.171 ...
#  $ LandR_SCFM_V6a   : num  0.144 0.144 0.144 0.171 0.144 ...
#  $ LandR.CS_SCFM_V4 : num  0.171 0.171 0.196 0.238 0.171 ...
#  $ LandR.CS_SCFM_V6a: num  0.144 0.144 0.144 0.171 0.144 ...



source("functions.R")

YRS <- YRS10
i_jurs <- which(JURS == "NT")
#i_scen <- 1
#i_year <- 1

rt <- rast(make_name(
    root=OUT1,
    api_ver="api/v1",
    access="public",
    project="wbi",
    region=names(JURS)[i_jurs],
    kind="elements",
    element="tree-popu-tre",
    scenario=names(SCENS)[1],
    period=YRS[1],
    resolution="250m",
    file="mean.tif"))


## biomass

for (i_scen in seq_along(SCENS)) {
    for (i_year in seq_along(YRS)) {
      
      message(paste(JURS[i_jurs], 
                    SCENS[i_scen], 
                    YRS[i_year]))
      
      rr <- list()
      for (i_run in 1:5) {
      #for (i_run in c(1,3,4,5)) {
        input <- paste0(
          ROOT, "/outputs/",
          JURS[i_jurs], "_",
          SCENS[i_scen], "_",
          "run0", i_run, "/",
          "simulatedBiomassMap_", YRS[i_year], "_year", YRS[i_year], ".tif")

        r <- rast(input)
        values(r)[is.na(values(r)) & !is.na(values(rt))] <- 0
        rr[[i_run]] <- r
        
      }
      rp <- (rr[[1]]+rr[[2]]+rr[[3]]+rr[[4]]+rr[[4]])/5
      #rp <- (rr[[1]]+rr[[3]]+rr[[4]]+rr[[4]])/5
      output <- make_name(
        root=OUT1,
        api_ver="api/v1",
        access="public",
        project="wbi",
        region=names(JURS)[i_jurs],
        kind="elements",
        element="biomass",
        scenario=names(SCENS)[i_scen],
        period=YRS[i_year],
        resolution="250m",
        file="mean.tif")
      s <- st_as_stars(rp)
      make_dir(dirname(output))
      write_stars(s, output, options = c("COMPRESS=LZW"))
      
    }
}

miss <- list()
for (i_scen in seq_along(SCENS)) {
  for (i_year in seq_along(YRS)) {
    for (i_run in 1:5) {
      input <- paste0(
        ROOT, "/outputs/",
        JURS[i_jurs], "_",
        SCENS[i_scen], "_",
        "run0", i_run, "/",
        "simulatedBiomassMap_", YRS[i_year], "_year", YRS[i_year], ".tif")
      if (!file.exists(input)) {
        message(input)
        print(length(miss))
        miss[[length(miss)+1]] <- input
      }
    }
  }
}
# Missing
#[1] "/mnt/volume_tor1_01/wbi/outputs2/outputs/YT_CNRM-ESM2-1_SSP585_run02/simulatedBiomassMap_2011_year2011.tif"
#[2] "/mnt/volume_tor1_01/wbi/outputs2/outputs/YT_CNRM-ESM2-1_SSP585_run02/simulatedBiomassMap_2021_year2021.tif"
#[3] "/mnt/volume_tor1_01/wbi/outputs2/outputs/YT_CNRM-ESM2-1_SSP585_run02/simulatedBiomassMap_2031_year2031.tif"
#[4] "/mnt/volume_tor1_01/wbi/outputs2/outputs/YT_CNRM-ESM2-1_SSP585_run02/simulatedBiomassMap_2041_year2041.tif"
#[5] "/mnt/volume_tor1_01/wbi/outputs2/outputs/YT_CNRM-ESM2-1_SSP585_run02/simulatedBiomassMap_2051_year2051.tif"
#[6] "/mnt/volume_tor1_01/wbi/outputs2/outputs/YT_CNRM-ESM2-1_SSP585_run02/simulatedBiomassMap_2061_year2061.tif"
#[7] "/mnt/volume_tor1_01/wbi/outputs2/outputs/YT_CNRM-ESM2-1_SSP585_run02/simulatedBiomassMap_2071_year2071.tif"
#[8] "/mnt/volume_tor1_01/wbi/outputs2/outputs/YT_CNRM-ESM2-1_SSP585_run02/simulatedBiomassMap_2081_year2081.tif"
#[9] "/mnt/volume_tor1_01/wbi/outputs2/outputs/YT_CNRM-ESM2-1_SSP585_run02/simulatedBiomassMap_2091_year2091.tif"
#[10] "/mnt/volume_tor1_01/wbi/outputs2/outputs/YT_CNRM-ESM2-1_SSP585_run02/simulatedBiomassMap_2100_year2100.tif"


## burn

for (i_year in seq_along(YRS)[-1]) {
  for (i_scen in seq_along(SCENS)[3:4]) {

      message(paste(JURS[i_jurs], 
                    SCENS[i_scen], 
                    YRS[i_year]))
      yy <- (YRS[i_year-1]+1):YRS[i_year]
      
      rrr <- NULL
      for (i_run in 1:5) {
        rr <- NULL
        for (y in yy) {
          message(i_run, " / ", y)
          input <- paste0(
            ROOT, "/outputs/",
            JURS[i_jurs], "_",
            SCENS[i_scen], "_",
            "run0", i_run, "/",
            "burnMap_", y, "_year", y, ".tif")
          r <- rast(input)
          values(r)[is.na(values(r)) & !is.na(values(rt))] <- 0
          if (is.null(rr)) {
            rr <- r
          } else {
            rr <- rr+r
          }
          
        }
        #values(rr)[!is.na(values(rr)) & values(rr) > 1] <- 1
        if (is.null(rrr)) {
          rrr <- rr
        } else {
          rrr <- rrr+rr
        }
        

      }
      
      output <- make_name(
        root=OUT1,
        api_ver="api/v1",
        access="public",
        project="wbi",
        region=names(JURS)[i_jurs],
        kind="elements",
        element="burn",
        scenario=names(SCENS)[i_scen],
        period=YRS[i_year],
        resolution="250m",
        file="mean.tif")
      s <- st_as_stars(rrr)
      make_dir(dirname(output))
      write_stars(s, output, options = c("COMPRESS=LZW"))
      
    }
}

miss2 <- list()
for (i_year in seq_along(YRS)[-1]) {
  for (i_scen in seq_along(SCENS)) {
    yy <- (YRS[i_year-1]+1):YRS[i_year]
    for (i_run in 1:5) {
      for (y in yy) {
        input <- paste0(
          ROOT, "/outputs/",
          JURS[i_jurs], "_",
          SCENS[i_scen], "_",
          "run0", i_run, "/",
          "burnMap_", y, "_year", y, ".tif")
        if (!file.exists(input)) {
          message(input)
          miss2[[length(miss2)+1]] <- input
        }
      }
    }
  }
}



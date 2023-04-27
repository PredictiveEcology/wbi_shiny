source("functions.R")

## birds -----------------------

#fl <- list.files(paste0(ROOT, "/SK/posthoc"), pattern="SK_CanESM5_SSP585_run05_predicted_")
#fl <- fl[endsWith(fl, "2011.tif")]
#fl <- gsub("SK_CanESM5_SSP585_run05_predicted_", "", fl)
#fl <- gsub("_Year2011\\.tif", "", fl)
#dput(fl)
BIRDS <- c("ALFL", "AMCR", "AMGO", "AMRE", "AMRO", "ATSP", "ATTW", "BAOR", 
           "BARS", "BAWW", "BBCU", "BBMA", "BBWA", "BBWO", "BCCH", "BEKI", 
           "BHCO", "BHVI", "BLBW", "BLJA", "BLPW", "BOBO", "BOCH", "BOWA", 
           "BRBL", "BRCR", "BTNW", "CAWA", "CCSP", "CEDW", "CHSP", "CMWA", 
           "COGR", "CONW", "CORA", "COYE", "CSWA", "DEJU", "DOWO", "EAKI", 
           "EAPH", "EUST", "EVGR", "FOSP", "GCFL", "GCKI", "GCSP", "GCTH", 
           "GRAJ", "GRCA", "GRYE", "HAFL", "HAWO", "HOLA", "HOSP", "HOWR", 
           "KILL", "LALO", "LCSP", "LEFL", "LEYE", "LISP", "MAWA", "MODO", 
           "MOWA", "NAWA", "NOFL", "NOWA", "OCWA", "OSFL", "OVEN", "PAWA", 
           "PHVI", "PIGR", "PISI", "PIWO", "PUFI", "RBGR", "RBNU", "RCKI", 
           "RECR", "REVI", "RUBL", "RUGR", "RWBL", "SAVS", "SEWR", "SOSA", 
           "SOSP", "SPSA", "SWSP", "SWTH", "TEWA", "TOSO", "TOWA", "TRES", 
           "VATH", "VEER", "VESP", "WAVI", "WBNU", "WCSP", "WETA", "WEWP", 
           "WIPT", "WISN", "WIWA", "WIWR", "WTSP", "WWCR", "YBFL", "YBSA", 
           "YEWA", "YHBL", "YRWA")
names(BIRDS) <- paste0("bird-", tolower(BIRDS))

#BIRDS <- BIRDS[which(BIRDS == "VESP"):length(BIRDS)]
#BIRDS <- BIRDS[which(BIRDS == "CORA"):length(BIRDS)]

# rt <- rast("https://peter.solymos.org/testapi/amro1k.tif")
# crsll <- crs(rt)

## copying birds

CHECK <- FALSE

YRS <- YRS20
i_jurs <- which(JURS == "NT")
i_scen <- 4

# i_year <- 1
# i_spec <- 1
#for (i_scen in seq_along(SCENS)) {
  for (i_spec in seq_along(BIRDS)) {
    for (i_year in seq_along(YRS)) {
      # files
      input <- paste0(
        ROOT, "/",
        JURS[i_jurs], "/",
        "posthoc/",
        JURS[i_jurs], "_",
        SCENS[i_scen], "_",
        "run0", 1:5,
        "_predicted_",
        BIRDS[i_spec],
        "_Year", YRS[i_year], ".tif")
      output <- make_name(
        root=OUT1,
        api_ver="api/v1",
        access="public",
        project="wbi",
        region=names(JURS)[i_jurs],
        kind="elements",
        element=names(BIRDS)[i_spec],
        scenario=names(SCENS)[i_scen],
        period=YRS[i_year],
        resolution="250m",
        file="mean.tif")
      WRITE <- TRUE
      if (CHECK && file.exists(output))
        WRITE <- FALSE

      if (WRITE) {
        message(paste(JURS[i_jurs], 
                      BIRDS[i_spec],
                      SCENS[i_scen], 
                      YRS[i_year]))
        rr <- list()
        for (i in 1:length(input)) {
          #message("\t- run ", i)
          rr[[i]] <- rast(input[i])
        }
        rp <- (rr[[1]]+rr[[2]]+rr[[3]]+rr[[4]]+rr[[4]])/5
        
        s <- st_as_stars(rp)
        make_dir(dirname(output))
        write_stars(s, output, options = c("COMPRESS=LZW"))
      }
            
    }
  }
#}

# 1 VEER, 3-TOWA
# Stopped: NT COYE CNRM-ESM2-1_SSP370 2071
# Stopped: NT COYE CanESM5_SSP370 2031
# Stopped: NT CORA CNRM-ESM2-1_SSP585 2091
# Stopped: NT CORA CanESM5_SSP585 2051

# Missing:
# NT VEER CNRM-ESM2-1_SSP370 2011
# NT TOWA CNRM-ESM2-1_SSP585 2051


# check which files are missing
miss <- list()
miss2 <- list()
for (i_scen in seq_along(SCENS)) {
  for (i_spec in seq_along(BIRDS)) {
    for (i_year in seq_along(YRS)) {
      
      # files
      input <- paste0(
        ROOT, "/",
        JURS[i_jurs], "/",
        "posthoc/",
        JURS[i_jurs], "_",
        SCENS[i_scen], "_",
        "run0", 1:5,
        "_predicted_",
        BIRDS[i_spec],
        "_Year", YRS[i_year], ".tif")
      output <- make_name(
        root=OUT1,
        api_ver="api/v1",
        access="public",
        project="wbi",
        region=names(JURS)[i_jurs],
        kind="elements",
        element=names(BIRDS)[i_spec],
        scenario=names(SCENS)[i_scen],
        period=YRS[i_year],
        resolution="250m",
        file="mean.tif")
      
      for (i in 1:length(input)) {
        if (!file.exists(input[i])) {
          message(input[i])
          miss[[length(miss)+1]] <- list(file=input[i],
                                         jurs=JURS[i_jurs],
                                         scene=SCENS[i_scen],
                                         run=i,
                                         species=BIRDS[i_spec],
                                         year=YRS[i_year])
        }
      }
      
      if (!file.exists(output)) {
        message(output)
        miss2[[length(miss2)+1]] <- list(file=output,
                                       jurs=JURS[i_jurs],
                                       scene=SCENS[i_scen],
                                       species=BIRDS[i_spec],
                                       year=YRS[i_year])
      }
      
    }
  }
}

length(miss)
length(miss2)
unique(sapply(miss2, "[[", "species"))
unique(sapply(miss2, "[[", "year"))

unique(sapply(miss, "[[", "run"))

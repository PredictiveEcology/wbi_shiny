source("functions.R")

## birds -----------------------

#fl <- list.files(paste0(ROOT, "/BC/posthoc"), pattern="BC_CanESM5_SSP585_run05_predicted_")
#fl <- fl[endsWith(fl, "2011.tif")]
#fl <- gsub("BC_CanESM5_SSP585_run05_predicted_", "", fl)
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

# rt <- rast("https://peter.solymos.org/testapi/amro1k.tif")
# crsll <- crs(rt)

## copying birds

YRS <- YRS20
i_jurs <- 4
i_scen <- 1
# i_year <- 1
# i_spec <- 1
#for (i_scen in seq_along(SCENS)) {
#for (i_scen in 3:4) {
  for (i_spec in seq_along(BIRDS)) {
    for (i_year in seq_along(YRS)) {
      
      message(paste(JURS[i_jurs], 
                    BIRDS[i_spec],
                    SCENS[i_scen], 
                    YRS[i_year]))
      
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
      
      rr <- list()
      for (i in 1:length(input)) {
        #message("\t- run ", i)
        rr[[i]] <- rast(input[i])
      }
      rp <- (rr[[1]]+rr[[2]]+rr[[3]]+rr[[4]]+rr[[4]])/5

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
      s <- st_as_stars(rp)
      make_dir(dirname(output))
      write_stars(s, output, options = c("COMPRESS=LZW"))
            
    }
  }
#}

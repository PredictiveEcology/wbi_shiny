source("functions.R")

## veg type / leading spp
ROOT <- "/mnt/volume_tor1_01/wbi/outputs"
TREES <- list(
  list(name = "Abie_bal", value = 1, id = "tree-abie-bal"),
  list(name = "Abie_las", value = 2, id = "tree-abie-las"),
  list(name = "Betu_pap", value = 3, id = "tree-betu-pap"),
  list(name = "Lari_lar", value = 4, id = "tree-lari-lar"),
  list(name = "Mixed",    value = 5, id = "tree-mixed"),
  list(name = "Pice_gla", value = 6, id = "tree-picea-gla"),
  list(name = "Pice_mar", value = 7, id = "tree-picea-mar"),
  list(name = "Pinu_ban", value = 8, id = "tree-pinu-ban"),
  list(name = "Pinu_con", value = 9, id = "tree-pinu-con"),
  list(name = "Popu_tre",value = 10, id = "tree-popu-tre"))


YRS <- YRS10

#i_jurs <- 1
#i_scen <- 1
#i_year <- 1
for (i_jurs in seq_along(JURS)) {
  for (i_scen in seq_along(SCENS)) {
    #for (i_year in seq_along(YRS)) {
 
      i_year <- 8     
      message(paste(JURS[i_jurs], 
                    SCENS[i_scen], 
                    YRS[i_year]))
      
      rr <- list()
      rn <- list()
      for (i_run in 1:5) {
        input <- paste0(
          ROOT, "/",
          JURS[i_jurs], "_",
          SCENS[i_scen], "_",
          "run0", i_run,
          "/postprocess/vegTypeMap_", YRS[i_year], ".tif")
        
        rr[[i_run]] <- rast(input)
        rn[[i_run]] <- as.numeric(rr[[i_run]])
      }
      # table(values(rr[[1]]),values(rr[[2]]))
      
      out <- list()
      for (i in 1:10) {
        message("\t- species ", i)
        r1 <- as.numeric(rn[[1]] == i)
        r2 <- as.numeric(rn[[2]] == i)
        r3 <- as.numeric(rn[[3]] == i)
        r4 <- as.numeric(rn[[4]] == i)
        r5 <- as.numeric(rn[[5]] == i)
        rp <- (r1+r2+r3+r4+r5)/5
        out[[TREES[[i]]$id]] <- rp
        
        output_i <- make_name(
          root=OUT1,
          api_ver="api/v1",
          access="public",
          project="wbi",
          region=names(JURS)[i_jurs],
          kind="elements",
          element=TREES[[i]]$id,
          scenario=names(SCENS)[i_scen],
          period=YRS[i_year],
          resolution="250m",
          file="mean.tif")
        s <- st_as_stars(rp)
        make_dir(dirname(output_i))
        write_stars(s, output_i, options = c("COMPRESS=LZW"))
        
      }

    #}
  }
}


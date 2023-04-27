source("functions.R")

i_scen <- 4
overwrite <- TRUE

# fl <- list.files(OUT1, recursive=TRUE)
# pp <- parse_path(fl)
# lapply(pp, table)
pp <- readRDS("/mnt/volume_tor1_01/wbi/final/maps.rds")
table(pp$region, pp$resolution)
#pp0 <- pp
# pp$path <- paste0(OUT1, "/", fl)
pp$path <- paste0(OUT1, "/", pp$path)
pp <- pp[pp$scenario == names(SCENS)[i_scen],]

pp <- pp[pp$region != "full-extent",]
pp <- pp[pp$resolution == "1000m",]
pp$match <- gsub(".*elements/", "", pp$path)

pp1 <- pp[pp$region == "ab",]
pp1$region <- "full-extent"
pp1$path <- gsub("/ab/", "/full-extent/", pp1$path)

#i <- 100
for (i in 1:nrow(pp)) {
  
  ppi <- pp[pp$match == pp1$match[i],]
  message("FULL EXTENT --- ", paste0(
    paste(names(ppi[1,][5:8]), 
          unname(unlist(ppi[1,][5:8])), sep="="), collapse=" "))
  
  rr <- list()
  for (j in 1:6) {
    rr[[ppi$region[j]]] <- st_as_stars(rast(ppi$path[j]))
  }
  # m <- rr[[1]]
  # for (j in 2:6) {
  #   m <- st_mosaic(m, rr[[j]])
  # }
  m <- st_mosaic(rr[[1]], rr[[2]], rr[[3]], rr[[4]], rr[[5]], rr[[6]])
  mll <- st_warp(m, crs=4326)
  
  ppo <- pp1[i,]
  ppoll <- ppo
  ppoll$resolution <- "lonlat"
  output1k <- make_name_from_list(ppo, OUT1)
  output1kll <- make_name_from_list(ppoll, OUT1)
  
  if (!file.exists(output1k) || overwrite) {
    message("\twriting 1k")
    make_dir(dirname(output1k))
    write_stars(m, output1k, options = c("COMPRESS=LZW"))
  }
  if (!file.exists(output1kll) || overwrite) {
    message("\twriting ll")
    make_dir(dirname(output1kll))
    write_stars(mll, output1kll, options = c("COMPRESS=LZW"))
  }
  
}

#r <- rast(output1k)
#rll <- rast(output1kll)

#r <- read_stars(output1k)
#rll <- read_stars(output1kll)

## get summaries

#fl <- list.files(OUT1, recursive=TRUE)
#pp <- parse_path(fl)
#pp$path <- fl
#arrow::write_parquet(pp, "/mnt/volume_tor1_01/wbi/final/maps.parquet")

source("functions.R")

i_scen <- 4

pp0 <- arrow::read_parquet("/mnt/volume_tor1_01/wbi/final/maps.parquet")

pp <- pp0[pp0$scenario == names(SCENS)[i_scen],]
pp <- pp[pp$resolution == "lonlat",]
lapply(pp[,colnames(pp) != "path"], table)

pp$fullpath <- paste0(OUT1, "/", pp$path)

Stats <- matrix(NA, nrow(pp), 6)
colnames(Stats) <- c("mean", "q0", "q50", "q99", "q999", "q1")

for (i in 1:nrow(pp)) {
  message(i, " / ", nrow(pp))
  s <- rast_stats2(pp$fullpath[i])
  Stats[i,] <- s
}

ppp <- data.frame(pp, Stats)
arrow::write_parquet(ppp, paste0("/mnt/volume_tor1_01/wbi/final/maps_", i_scen, ".parquet"))

#system.time(rast_stats(pp$fullpath[1]))
#system.time(rast_stats(pp$fullpath[2]))
#system.time(rast_stats2(pp$fullpath[1]))
#system.time(rast_stats2(pp$fullpath[2]))

p1 <- arrow::read_parquet("/mnt/volume_tor1_01/wbi/final/maps_1.parquet")
p2 <- arrow::read_parquet("/mnt/volume_tor1_01/wbi/final/maps_2.parquet")
p3 <- arrow::read_parquet("/mnt/volume_tor1_01/wbi/final/maps_3.parquet")
p4 <- arrow::read_parquet("/mnt/volume_tor1_01/wbi/final/maps_4.parquet")
pps <- rbind(p1, p2, p3, p4)

pp0s <- data.frame(pp0, 
    pps[match(pp0$path, pps$path),
        !(colnames(pps) %in% colnames(pp0))])
pp0s$fullpath <- NULL
colSums(is.na(pp0s)) |> data.frame(n=_)

saveRDS(pp0s, "/mnt/volume_tor1_01/wbi/final/maps-with-stats.rds")
n <- readRDS("/mnt/volume_tor1_01/wbi/final/maps-with-stats.rds")
arrow::write_parquet(n, "/mnt/volume_tor1_01/wbi/final/maps-with-stats.parquet")

pps$fullpath <- NULL
arrow::write_parquet(pps, "/mnt/volume_tor1_01/wbi/final/maps-lonlat-with-stats.parquet")
saveRDS(pps, "/mnt/volume_tor1_01/wbi/final/maps-lonlat-with-stats.rds")

saveRDS(pp0, "/mnt/volume_tor1_01/wbi/final/maps.rds")


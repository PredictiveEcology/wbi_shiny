source("functions.R")

i_scen <- 4

overwrite <- TRUE
q <- 1

fl <- list.files(OUT1, recursive=TRUE)

# cleanup
#  flx <- fl[grep("/2080/", fl)]
#  unlink(paste0(OUT1, "/", flx))

pp <- parse_path(fl)
pp <- pp[pp$scenario == names(SCENS)[i_scen],]
pp <- pp[pp$region == "ab",]
pp <- pp[pp$resolution == "250m",]
pp <- pp[!startsWith(pp$element, "tree"),]
lapply(pp, table)

## process scales
for (i in 1:nrow(pp)) {
  p0 <- pp[i,]
  message(paste0(
    paste(names(p0[4:8]), 
          unname(unlist(p0[4:8])), sep="="), collapse=" "))
  
  p1k <- p0
  p1k$resolution <- "1000m"
  p1kll <- p0
  p1kll$resolution <- "lonlat"
  input <- make_name_from_list(p0, OUT1)

  r <- rast(input)
  # might have to make this depend on element name, startsWith bird or tree
  if (q < 1) {
    qv <- quantile(values(r), q, na.rm=TRUE)
    values(r)[!is.na(values(r)) & values(r) > qv] <- qv
  }

  s <- st_as_stars(r)
  r1k <- aggregate(r, fact=4)
  s1k <- st_as_stars(r1k)
  #s1kll <- st_transform(s1k, "EPSG:4326")
  s1kll <- st_warp(s1k, crs=4326)
  
  output1k <- make_name_from_list(p1k, OUT1)
  output1kll <- make_name_from_list(p1kll, OUT1)
  
  if (!file.exists(output1k) || overwrite) {
    message("\tsaving 1k")
    make_dir(dirname(output1k))
    write_stars(s1k, output1k, options = c("COMPRESS=LZW"))
  }
  if (!file.exists(output1kll) || overwrite) {
    message("\tsaving lonlat")
    make_dir(dirname(output1kll))
    write_stars(s1kll, output1kll, options = c("COMPRESS=LZW"))
  }
  
}

#flx <- fl[grep("/lonlat/", fl)][190]
#rx <- rast(paste0(OUT1, "/", flx))
#r2 <- rast("https://wbi.predictiveecology.org/api/v1/public/wbi-nwt/elements/bird-alfl/landr-scfm-v4/2011/lonlat/mean.tif")

## need to audit the layers and pull out statistics
library(future)
plan(multisession, workers = 4)

fl <- list.files(OUT1, recursive=TRUE)
#fl <- fl[1:10]
pp <- parse_path(fl)
st <- pbapply::pblapply(fl, function(z) {rast_stats(paste0(OUT1, "/", z))},
                        cl="future")
ppp <- data.frame(pp, do.call(rbind, st), link=fl)
arrow::write_parquet(ppp, "links-and-stats.parquet")

ppp <- arrow::read_parquet("links-and-stats.parquet")

lapply(pp, table)
ppp$group <- substr(ppp$element, 1, 4)
table(ppp$group)

by(ppp[,c("mean", "q0", "q50", "q99", "q999", "q1")], list(group=ppp$group), summary)


fl1 <- fl[startsWith(fl, "api/v1/public/wbi/ab/")]
fl1 <- fl1[grep("/250m/", fl1)]
fl1 <- gsub("api/v1/public/wbi/ab/", "", fl1)

fl2 <- fl[startsWith(fl, "api/v1/public/wbi/bc/")]
fl2 <- fl2[grep("/250m/", fl2)]
fl2 <- gsub("api/v1/public/wbi/bc/", "", fl2)

fl1 <- fl[grep("/250m/", fl)]
fl2 <- fl[grep("/1000m/", fl)]
fl2 <- gsub("/1000m/", "/250m/", fl2)

mefa4::compare_sets(fl1,fl2)

setdiff(fl1,fl2)
setdiff(fl2,fl1)

table(pp$resolution, pp$region)
p <- pp[pp$resolution=="250m",]
u <- table(p$element, p$region)
u <- u[rowSums(u) != 120,]
u <- u[rowSums(u) != 240,]

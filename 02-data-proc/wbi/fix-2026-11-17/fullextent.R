# Rebuild full-extent tree maps from the relabelled regional 1000m maps, exactly
# as 02-data-proc/wbi/05-full-extent.R does (st_mosaic of ab,bc,mb,nt,sk,yt;
# st_warp to EPSG:4326). Verified to reproduce a published biomass map bit-for-bit.
.libPaths(c("rlib", .libPaths()))
suppressMessages({library(stars); library(terra); library(parallel)})
LIVE <- "newArbutus:predictiveecology/wbi/api/v1/public/wbi"
R6 <- c("ab", "bc", "mb", "nt", "sk", "yt")
EL <- c("tree-abie-bal", "tree-abie-las", "tree-betu-pap", "tree-lari-lar", "tree-mixed",
        "tree-picea-gla", "tree-picea-mar", "tree-pinu-ban", "tree-pinu-con", "tree-popu-tre")
work <- "fe_work"; dir.create(work, showWarnings = FALSE)

# Pull every regional 1000m tree map once.
for (r in R6) system2("rclone", shQuote(c("copy", "--transfers", "32", "--include", "/tree-*/*/*/1000m/mean.tif",
                                           sprintf("%s/%s/elements", LIVE, r), file.path(work, "in", r))))
combos <- expand.grid(el = EL, sc = c("canesm5-ssp370", "canesm5-ssp585", "cnrm-esm2-1-ssp370", "cnrm-esm2-1-ssp585"),
                      yr = c(2011, 2021, 2031, 2041, 2051, 2061, 2071, 2081, 2091, 2100), stringsAsFactors = FALSE)
done <- mclapply(seq_len(nrow(combos)), function(i) {
  with(combos[i, ], {
    rel <- file.path(el, sc, yr)
    rr <- lapply(R6, function(r) st_as_stars(rast(file.path(work, "in", r, rel, "1000m", "mean.tif"))))
    m <- st_mosaic(rr[[1]], rr[[2]], rr[[3]], rr[[4]], rr[[5]], rr[[6]])
    mll <- st_warp(m, crs = 4326)
    o <- file.path(work, "out", rel); dir.create(file.path(o, "1000m"), recursive = TRUE, showWarnings = FALSE)
    dir.create(file.path(o, "lonlat"), showWarnings = FALSE)
    write_stars(m, file.path(o, "1000m", "mean.tif"), options = "COMPRESS=LZW")
    write_stars(mll, file.path(o, "lonlat", "mean.tif"), options = "COMPRESS=LZW")
    TRUE
  })
}, mc.cores = 6)
stopifnot(all(vapply(done, isTRUE, TRUE)))
n <- length(list.files(file.path(work, "out"), recursive = TRUE))
message("built ", n, " files")
stopifnot(n == 800)
if (identical(commandArgs(TRUE)[1], "upload"))
  system2("rclone", shQuote(c("copy", "--s3-acl", "public-read", "--transfers", "32", "--ignore-times",
                               file.path(work, "out"), sprintf("%s/full-extent/elements", LIVE))))

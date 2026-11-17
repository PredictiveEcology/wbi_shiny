suppressMessages({library(terra); library(parallel)})
source(textConnection(readLines("wbi_shiny/02-data-proc/wbi/functions.R")[76:83]))   # rast_stats
L0 <- readRDS("rds/links-and-stats.rds"); L <- L0
cols <- c("mean", "q0", "q50", "q99", "q999", "q1")
CODE_EL <- c("tree-abie-bal","tree-abie-las","tree-betu-pap","tree-lari-lar","tree-mixed",
             "tree-picea-gla","tree-picea-mar","tree-pinu-ban","tree-pinu-con","tree-popu-tre")
plan <- local({ e <- new.env(); src <- readLines("relabel.R")
  eval(parse(text = src[grep("^CODE_EL", src):grep("^print\\(plan", src) - 1]), e); e$plan })
key <- function(d, el) paste(d$region, el, d$scenario, d$period, d$resolution)
k0 <- key(L0, L0$element)
nPerm <- 0; nZero <- 0
for (i in seq_len(nrow(plan))) {
  rows <- which(L$region == plan$region[i] & L$element == plan$dst[i])
  if (is.na(plan$src[i])) { L[rows, cols] <- 0; nZero <- nZero + length(rows) }
  else { j <- match(key(L[rows, ], plan$src[i]), k0); stopifnot(!anyNA(j))
         L[rows, cols] <- L0[j, cols]; nPerm <- nPerm + length(rows) }
}
fe <- which(L$region == "full-extent" & startsWith(L$element, "tree-"))
st <- mclapply(fe, function(r) rast_stats(file.path("fe_work/out", L$element[r], L$scenario[r], L$period[r], L$resolution[r], "mean.tif")), mc.cores = 8)
L[fe, cols] <- do.call(rbind, st)
cat("permuted", nPerm, " zero", nZero, " full-extent recomputed", length(fe), "\n")
cat("rows changed:", sum(rowSums(L[, cols] != L0[, cols], na.rm=TRUE) > 0), " non-tree rows changed:", sum(rowSums(L[!startsWith(L$element,"tree-"), cols] != L0[!startsWith(L0$element,"tree-"), cols], na.rm=TRUE) > 0), "\n")
saveRDS(L, "links-and-stats.new.rds")

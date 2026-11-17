# Recompute Regions-tab statistics for the tree rows from the rebuilt full-extent 1000m maps,
# following 07-regional-summaries.R, but with the app's own (1 km-simplified) BCR x province
# polygons because the original BCR shapefile is no longer downloadable.
suppressMessages({library(terra); library(sf); library(parallel)})
s0 <- readRDS("ers_old.rds"); s <- s0
el <- s$elements; W <- "WBI: Western Boreal Initiative"
cc <- which(s$regions$classification == "BCR / Jurisdiction"); reg <- s$regions$region[cc]
tmpl <- rast("fe/full.tif")                                   # full-extent 1000m grid (biomass 2051)
zp <- vect(s$regions[cc, ]); zp$id <- seq_along(cc)
cls <- rasterize(zp, tmpl, field = "id")                     # last polygon wins on overlap, as 07 did
cv <- values(cls)[, 1]
regstat <- function(v) { ok <- !is.na(v) & !is.na(cv)
  sm <- tapply(v[ok], factor(cv[ok], levels = seq_along(cc)), sum); n <- tabulate(cv[ok], length(cc))
  list(S = ifelse(is.na(sm), 0, sm), N = n) }
agg <- function(S, N) {
  bcr <- sub(" - .*", "", reg); jur <- sub(".* - ", "", reg)
  m <- c(sum(S)/sum(N), tapply(S, bcr, sum)/tapply(N, bcr, sum), tapply(S, jur, sum)/tapply(N, jur, sum), S/N)
  n <- c(sum(N), tapply(N, bcr, sum), tapply(N, jur, sum), N)
  names(m)[1] <- names(n)[1] <- W; names(m)[-(1:(1+4+7))] <- names(n)[-(1:(1+4+7))] <- reg
  list(m = m[colnames(s$statistics$mean)], n = n[colnames(s$statistics$mean)]) }
# Validation on an unchanged element: biomass 2051 canesm5-ssp370 (the template map itself).
i <- which(el$element == "biomass" & el$scenario == "canesm5-ssp370" & el$period == "2051")
r <- regstat(values(tmpl)[, 1]); a <- agg(r$S, r$N)
cmp <- data.frame(stored_mean = s0$statistics$mean[i, ], new_mean = a$m, rel_diff_pct = round(100*(a$m/s0$statistics$mean[i, ] - 1), 2),
                  stored_npix = s0$statistics$npix[i, ], new_npix = a$n)
print(cmp)
if (identical(commandArgs(TRUE)[1], "apply")) {
  tree <- which(startsWith(el$element, "tree-"))
  res <- mclapply(tree, function(r) { v <- values(rast(file.path("fe_work/out", el$element[r], el$scenario[r], el$period[r], "1000m", "mean.tif")))[, 1]
    x <- regstat(v); agg(x$S, x$N) }, mc.cores = 8)
  for (k in seq_along(tree)) { s$statistics$mean[tree[k], ] <- res[[k]]$m; s$statistics$npix[tree[k], ] <- as.integer(res[[k]]$n) }
  saveRDS(s, "wbi_shiny/03-apps/wbi/data-raw/elements-regions-stats-1000m.rds")
  cat("updated", length(tree), "tree rows\n")
}

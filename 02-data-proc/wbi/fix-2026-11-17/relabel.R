# Relabel WBI regional tree maps. 04-trees.R wrote vegTypeMap code k as
# TREES[[k]] (Alberta's order) in every province; the real species for code k is
# the k-th of that province's levels: sort(c(species simulated there, "Mixed")).
# Species lists: PredictiveEcology/WBI_dataPrep_studyArea R/sppEquiv.R.
# Sources are read from the backup, so a re-run is safe.
suppressMessages(library(terra))
args <- commandArgs(TRUE)
mode <- if (length(args)) args[1] else "dry"   # "dry", "copy" or "zeros"

LIVE <- "newArbutus:predictiveecology/wbi/api/v1/public/wbi"
BAK  <- "newArbutus:predictiveecology/wbi-backup-20261117-trees"
CODE_EL <- c("tree-abie-bal", "tree-abie-las", "tree-betu-pap", "tree-lari-lar", "tree-mixed",
             "tree-picea-gla", "tree-picea-mar", "tree-pinu-ban", "tree-pinu-con", "tree-popu-tre")
SPP_EL <- c(Abie_bal = "tree-abie-bal", Abie_las = "tree-abie-las", Betu_pap = "tree-betu-pap",
            Lari_lar = "tree-lari-lar", Mixed = "tree-mixed", Pice_gla = "tree-picea-gla",
            Pice_mar = "tree-picea-mar", Pinu_ban = "tree-pinu-ban", Pinu_con = "tree-pinu-con",
            Popu_tre = "tree-popu-tre")   # Pice_eng (BC only) has no element: dropped
LEVELS <- list(
  bc = c("Abie_las", "Betu_pap", "Lari_lar", "Mixed", "Pice_eng", "Pice_gla", "Pice_mar", "Pinu_con", "Popu_tre"),
  sk = c("Abie_bal", "Betu_pap", "Lari_lar", "Mixed", "Pice_gla", "Pice_mar", "Pinu_ban", "Popu_tre"),
  mb = c("Abie_bal", "Betu_pap", "Lari_lar", "Mixed", "Pice_gla", "Pice_mar", "Pinu_ban", "Popu_tre"),
  yt = c("Abie_las", "Betu_pap", "Lari_lar", "Mixed", "Pice_gla", "Pice_mar", "Pinu_con", "Popu_tre"),
  nt = c("Betu_pap", "Lari_lar", "Mixed", "Pice_gla", "Pice_mar", "Pinu_ban", "Popu_tre"))
stopifnot(all(vapply(LEVELS, function(l) identical(l, sort(l, method = "radix")), TRUE)))

rc <- function(...) {
  a <- c(...)
  if (mode == "dry") { cat("rclone", a, "\n"); return(invisible(0)) }
  st <- system2("rclone", shQuote(a))
  if (st != 0) stop("rclone failed: ", paste(a, collapse = " "))
}

plan <- do.call(rbind, lapply(names(LEVELS), function(reg) {
  L <- LEVELS[[reg]]
  m <- data.frame(region = reg, src = CODE_EL[seq_along(L)], species = L,
                  dst = unname(SPP_EL[L]))
  m <- m[!is.na(m$dst), ]
  absent <- setdiff(SPP_EL, m$dst)
  rbind(m, if (length(absent)) data.frame(region = reg, src = NA, species = names(SPP_EL)[match(absent, SPP_EL)], dst = absent))
}))
print(plan, row.names = FALSE)

if (mode %in% c("dry", "copy")) {
  for (i in which(!is.na(plan$src))) with(plan[i, ],
    rc("copy", "--s3-acl", "public-read", "--transfers", "32", "--checkers", "32",
       "--ignore-times", sprintf("%s/%s/elements/%s", BAK, region, src),
       sprintf("%s/%s/elements/%s", LIVE, region, dst)))
}

if (mode == "zeros") {
  # All-zero map for each species a province did not simulate, shaped like that
  # province's code-1 map for the same scenario/period/resolution (same NA mask).
  stage <- file.path(tempdir(), "zeros"); dir.create(stage)
  for (reg in unique(plan$region[is.na(plan$src)])) {
    absent <- plan$dst[plan$region == reg & is.na(plan$src)]
    srcdir <- file.path(stage, "src", reg); dir.create(srcdir, recursive = TRUE)
    rc("copy", "--transfers", "32", sprintf("%s/%s/elements/%s", BAK, reg, CODE_EL[1]), srcdir)
    fs <- list.files(srcdir, recursive = TRUE, pattern = "mean\\.tif$")
    for (f in fs) {
      r <- rast(file.path(srcdir, f))
      z <- classify(r, cbind(-Inf, Inf, 0))      # NA stays NA
      for (el in absent) {
        out <- file.path(stage, "out", reg, el, f); dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
        writeRaster(z, out, datatype = datatype(r), gdal = "COMPRESS=LZW", overwrite = TRUE)
      }
    }
    for (el in absent) rc("copy", "--s3-acl", "public-read", "--transfers", "32", "--ignore-times",
                          file.path(stage, "out", reg, el), sprintf("%s/%s/elements/%s", LIVE, reg, el))
    message(reg, ": ", length(fs), " zero maps x ", length(absent), " species")
  }
}

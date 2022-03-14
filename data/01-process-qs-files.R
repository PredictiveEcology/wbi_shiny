## Process large bird result files
## chunk results into series of nested directories
## writing parquet files instead of qs
## Input file: ALFL_rastersSummaryTable.qs

# Classes ‘data.table’ and 'data.frame':	381193620 obs. of  12 variables:
#  $ LandR_fS_V4      : num  0.181 0.18 0.196 0.253 0.184 ...
#  $ location         : num  2 2 2 2 2 2 2 2 2 NA ...
#  $ pixelID          : int  38546 38547 38548 38549 41470 41471 41472 41473 41474 41475 ...
#  $ Run              : chr  "run1" "run1" "run1" "run1" ...
#  $ Year             : num  2011 2011 2011 2011 2011 ...
#  $ LandR_fS_V6a     : num  0.143 0.143 0.144 0.171 0.143 ...
#  $ LandR.CS_fS_V4   : num  0.181 0.18 0.196 0.253 0.184 ...
#  $ LandR.CS_fS_V6a  : num  0.143 0.143 0.144 0.171 0.143 ...
#  $ LandR_SCFM_V4    : num  0.171 0.171 0.196 0.238 0.171 ...
#  $ LandR_SCFM_V6a   : num  0.144 0.144 0.144 0.171 0.144 ...
#  $ LandR.CS_SCFM_V4 : num  0.171 0.171 0.196 0.238 0.171 ...
#  $ LandR.CS_SCFM_V6a: num  0.144 0.144 0.144 0.171 0.144 ...


## Output: <species>/<year>/<run>/part-0.parquet

# FileSystemDataset with 1 Parquet file
# land_r_f_s_v4: double
# location: double
# pixel_id: int32
# land_r_f_s_v6a: double
# land_r_cs_f_s_v4: double
# land_r_cs_f_s_v6a: double
# land_r_scfm_v4: double
# land_r_scfm_v6a: double
# land_r_cs_scfm_v4: double
# land_r_cs_scfm_v6a: double

if (!require("Require")) {
  install.packages("Require")
  library("Require")
}
Require(c("qs", "arrow", "dplyr", "janitor"))

dataDir <- if (grepl("for-cast[.]ca", Sys.info()[["nodename"]])) {
  file.path("/mnt/wbi_data/NWT/outputs/PAPER_EffectsOfClimateChange/posthoc/summaryRasters")
} else {
  "."
}

finp <- list.files(file.path(dataDir, "qsfiles"), full.names = TRUE, pattern = "qs")

Require::checkPath(file.path(dataDir, "arrow"), create = TRUE)

for (i in seq_along(finp)) {
  message(finp[i])
  fout <- gsub("qsfiles", "arrow", finp[i])
  fout <- gsub("[.]qs", "", fout)
  if (!file.exists(fout)) {
    d <- qread(finp[i])

    d <- d %>%
      clean_names() %>%
      as_tibble()

    Y <- unique(d$year)

    j <- 1

    for (y in Y) {
      message(y)
      if (j == 1) {
        d <- d %>%
          filter(year == y) %>%
          group_by(year, run)

        gc()

        d %>%
          write_dataset(fout)

        rm(d); gc()

        j <- j + 1
      } else {
        d <- qread(finp[i]) %>%
          clean_names() %>%
          as_tibble() %>%
          filter(year == y) %>%
          group_by(year, run)

        d %>%
          write_dataset(fout)

        rm(d); gc()
      }
    }
  }
}

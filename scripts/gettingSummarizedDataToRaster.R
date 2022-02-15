# SCENARIOS
#  LandR: non-climate-sensitive version of forest growth model
#  LandR.CS: climate-sensitive version of forest growth model
#  SCFM: non-climate-sensitive version of wildfire model
#  fS: climate-sensitive version of wildfire model
#  V4: non-climate-sensitive version of bird model
#  V6a: climate-sensitive version of bird model
#    i.e., Fully non-climate sensitive model: LandR_SCFM_V4
#    i.e., Fully climate sensituive model: LandR.CS_fS_V6a
# RUN: each Run (i.e., "run1") is a replicate for stochastic processes# YEAR: each Year of the simulations
# pixelID: Index to match the raster

# Load/install 
libraries:if (!require("Require")) {
  install.packages("Require")
}
library("Require")
Require("googledrive")
Require("reproducible")
Require("qs")
Require("raster")

# To extract data from the table to the raster 
# 1. Load the table:
tb <- qread("~/AMCR_rastersSummaryTable.qs")

# 2. Load the template raster:
templateRas <- prepInputs(url = paste0("https://drive.google.com/file/d/",
                                       "117UqLDcsICMhvp6EWif3sK47ibuL1xfY/",
                                       "view?usp=sharing"), 
                          targetFile = "templateRaster.tif", 
                          destinationPath = tempdir())

# 3. Select one Run, one Year, and one SCENARIO (ex. run1, year 2011 and 
# scenario full climate sensitive)
tbCS <- tb[Run == "run1" & Year == "2011", c("pixelID", "LandR.CS_fS_V6a")]

# 4. Fill in the table with missing NA's:
tbCS <- merge(data.table(pixelID = 1:ncell(templateRas)), tbCS, all.x = TRUE)

# 5. Set the values to the raster:
csRas <- setValues(x = templateRas, values = tbCS[["LandR.CS_fS_V6a"]])
plot(csRas)

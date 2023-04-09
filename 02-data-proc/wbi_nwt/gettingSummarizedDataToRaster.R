## qs data processing script provided by T. Micheletti

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


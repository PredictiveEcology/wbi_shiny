## run the mock shiny app

shiny::runApp("mock")

a <- st_read("data/regions/nwt-bcr6.gpkg")
p <- st_read("data/regions/regions.gpkg")
a$classification <- "StudyArea"
a$region <- "NWT"
a$area <- st_area(a)
p <- rbind(a[,colnames(p)], p)

# add interactive maps to a ggplot -------
library(ggplot2)
library(ggiraph)

z <- p[p$classification == "Ecoregions",]
z$labs <- sprintf("<p>%s</p>", paste("Ecoregion", z$region))

gg <- ggplot(z) +
    geom_sf(aes(fill = as.numeric(area))) +
    geom_sf_label_interactive(aes(label = labs, tooltip = labs))
x <- girafe( ggobj = gg)

mp <- map_data("world")
gg_map <- ggplot(z, aes(map_id = region))
gg_map <- gg_map + geom_map_interactive(aes(
                  tooltip = labs,
                  data_id = region
                ),
                map = mp)# +
                #expand_limits(x = mp$long, y = mp$lat)

x <- girafe(ggobj = gg_map)

if (require("maps") ) {
  states_map <- map_data("state")
  gg_map <- ggplot(crimes, aes(map_id = state))
  gg_map <- gg_map + geom_map_interactive(aes(
                  fill = Murder,
                  tooltip = labs,
                  data_id = state,
                  onclick = onclick
                ),
                map = states_map) +
    expand_limits(x = states_map$long, y = states_map$lat)
  x <- girafe(ggobj = gg_map)
  if( interactive() ) print(x)
}

## GeoTIFF example

library(leaflet)
library(leafem)
library(raster)

URL <- "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/bird-amro/landr-scfm-v4/2011/1000m/mean.tif"
URL <- "https://peter.solymos.org/testapi/amro1k.tif"

r <- raster(URL)

## EPSG:4326
rr <- projectRaster(r, crs=crs("+proj=longlat +datum=WGS84 +no_defs "))
writeRaster(rr, "tmp.tif", overwrite=TRUE)
rr <- raster("tmp.tif")

leaflet() %>%
  #addTiles() %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addRasterImage(rr)

leaflet() %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addGeotiff(file = "tmp.tif")

leaflet() %>%
  #addTiles() %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addGeotiff(
    #file = tmpfl
    url = URL
    , opacity = 0.9
    , colorOptions = colorOptions(
      palette = hcl.colors(256, palette = "inferno")
      , na.color = "transparent"
    )
  )

  library(leafem)
  library(stars)

  tif = system.file("tif/L7_ETMs.tif", package = "stars")
  x1 = read_stars(tif)
  x1 = x1[, , , 3] # band 3

  tmpfl = tempfile(fileext = ".tif")

  write_stars(st_warp(x1, crs = 4326), tmpfl)

  leaflet() %>%
    addTiles() %>%
    addGeotiff(
      file = tmpfl
      , opacity = 0.9
      , colorOptions = colorOptions(
        palette = hcl.colors(256, palette = "inferno")
        , na.color = "transparent"
      ),
      autozoom = TRUE)

  ## there is also an unexported addCOG()

library(shiny)

## note Leaflet is having problem with CORS requests
shinyApp(
  ui=fluidPage(
    leafletOutput("map")
  ),
  server=function(input, output) {
    output$map <- renderLeaflet({
      leaflet() %>%
        addProviderTiles("Esri.WorldImagery") %>%
        addGeotiff(
          url = "https://peter.solymos.org/testapi/amro1k.tif",
          project = FALSE,
          opacity = 0.8,
          colorOptions = colorOptions(
             palette = hcl.colors(50, palette = "inferno"), 
             domain = c(0, 0.62),
             na.color = "#00000000"))
    })
  }
)

## pretty cool
# https://gatesdupontvignettes.com/2020/03/21/eBirdST-for-states.html

## Add measurement
leaflet() %>% addTiles() %>% addMeasure()
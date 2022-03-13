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
library(leaflet)
library(leafem)

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
          url = "https://peter.solymos.org/testapi/amro1k-stars.tif",
          project = FALSE,
          opacity = 0.8,
          colorOptions = colorOptions(
             palette = hcl.colors(50, palette = "inferno"), 
             domain = c(0, 0.62),
             na.color = "transparent"))
    })
  }
)

## pretty cool
# https://gatesdupontvignettes.com/2020/03/21/eBirdST-for-states.html

## Add measurement
leaflet() %>% addTiles() %>% addMeasure()

## Opacity slider
# https://cran.r-project.org/web/packages/leaflet.opacity/vignettes/leaflet-opacity.html

library(raster)
r <- raster("https://peter.solymos.org/testapi/amro1k.tif")
NAvalue(r)
NAvalue(r) <- -9999
NAvalue(r)
plot(r)
#writeRaster(r, "amro1k9999.tif")
#r <- raster("https://peter.solymos.org/testapi/amro1k9999.tif")
#NAvalue(r)

library(stars)
s <- st_as_stars(r)
write_stars(s, "amro1k-stars.tif")

## Make an app where color palettes can be picked

plot_pal <- function(pal, pch=15) {
  plot(seq_along(pal), rep(0, length(pal)), 
    col=pal, pch=pch, cex=5, axes=FALSE, ann=FALSE)
}

get_pal <- function(n=50, type=c("viridis", "rdylbu", "bam")) {
  switch(match.arg(type),
    "viridis" = viridis::viridis_pal(option = "D")(n),
    "rdylbu" = grDevices::hcl.colors(n, "RdYlBu", rev = TRUE),
    "bam" = grDevices::colorRampPalette(
        c("#FFFACD", "lemonchiffon","#FFF68F", "khaki1","#ADFF2F", 
        "greenyellow", "#00CD00", "green3", "#48D1CC", "mediumturquoise", 
        "#007FFF", "blue"), space="Lab", bias=0.5)(n))
}

# get_pal(50, "viridis") |> plot_pal()
# get_pal(50, "rdylbu") |> plot_pal()
# get_pal(50, "bam") |> plot_pal()

base <- function(type) {
  map_attr = "© <a href='https://www.esri.com/en-us/home'>ESRI</a> © <a href='https://www.google.com/maps/'>Google</a> © <a href='https://ebird.org/science/status-and-trends'>eBird / Cornell Lab of Ornithology</a> © <a href='https://www.gatesdupont.com/'>Gates Dupont</a>"
  leaflet() %>%
  addTiles(urlTemplate = "http://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}&s=Ga",
          group  =  "Google") %>%
  addProviderTiles("CartoDB.Positron", group = "CartoDB") %>%
  addProviderTiles("OpenStreetMap", group = "Open Street Map") %>%
  addProviderTiles('Esri.WorldImagery', group = "ESRI") %>%
  addTiles(urlTemplate = "", attribution = map_attr) %>%
  addLayersControl(
    baseGroups = c("ESRI", "Open Street Map", "CartoDB", "Google"),
    options = layersControlOptions(collapsed = FALSE)) %>%
  setView(-120, 65, 5)

}
lfun <- function(map, type="viridis", opacity=0.8) {
  addGeotiff(map,
      url = "https://peter.solymos.org/testapi/amro1k-stars.tif",
      project = FALSE,
      opacity = opacity,
      autozoom = FALSE,
      layerId = "raster",
      colorOptions = colorOptions(
        palette = get_pal(50, type), 
        domain = c(0, 0.62),
        na.color = "transparent")) %>%
    addLegend(pal = colorNumeric(palette=get_pal(50, type), domain = c(0, 0.62)), 
      values = c(0, 0.62),
      title = "Abundance")
}

library(shiny)
library(leaflet)
library(leafem)

shinyApp(
  ui=fluidPage(
    sidebarLayout(
      sidebarPanel(
        h1("Color Palette Test"),
        selectInput("type", "Color palette:", c("viridis", "rdylbu", "bam")),
        sliderInput("opacity", label = "Opacity:", 
                        min = 0, value = 0.8, max = 1),
        p("Please try the 3 palettes and change the base map.",
        "Provide feedback by filling out the form at the bottom of the page. Thanks!")
      ),
       mainPanel(
        leafletOutput("map", width = "100%", height = 600),
        HTML(Form)
       )
    )
  ),
  server=function(input, output) {
    output$map <- renderLeaflet({
      base() %>%
        lfun(input$type, input$opacity)
    })
  }
)

base() %>% lfun()

Form <- '<div id="my-reform"></div>

<script>window.Reform=window.Reform||function(){(Reform.q=Reform.q||[]).push(arguments)};</script>
<script id="reform-script" async src="https://embed.reform.app/v1/embed.js"></script>
<script>
    Reform("init", {
        url: "https://forms.reform.app/analythium/wbi-palette-test/lulyw8",
        target: "#my-reform",
        background: "default",
    })
</script>'
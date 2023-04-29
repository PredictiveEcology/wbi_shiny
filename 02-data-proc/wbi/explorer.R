## A mini data explorer

library(shiny)
library(leaflet)
library(leafem)

## ---------- functions --------------

read_with <- function(FUN, url, ...) {
    FUN <- match.fun(FUN)
    tmp <- tempfile(fileext = paste0(".", tools::file_ext(url)))
    on.exit(unlink(tmp), add = TRUE)
    download.file(url, tmp)
    FUN(tmp, ...)
}

# source("https://raw.githubusercontent.com/PredictiveEcology/wbi_shiny/wbi-full-extent/03-apps/wbi_nwt/R/fct_map.R")

make_name <- function(
    root=".",
    api_ver="api/v1",
    access="public",
    project="wbi",
    region,
    kind="elements",
    element,
    scenario,
    period,
    resolution,
    file) {
  paste(
    root,
    api_ver,
    access,
    project,
    region,
    kind,
    element,
    scenario,
    period,
    resolution,
    file,
    sep="/")
}

get_pal <- function(n=50, type=c("viridis", "rdylbu", "spectral", "bam")) {
  switch(match.arg(type),
    "viridis" = viridis::viridis_pal(option = "D")(n),
    "rdylbu" = grDevices::hcl.colors(n, "RdYlBu", rev = TRUE),
    "spectral" = grDevices::hcl.colors(n, "spectral", rev = TRUE),
    "bam" = grDevices::colorRampPalette(
        c("#FFFACD", "lemonchiffon","#FFF68F", "khaki1","#ADFF2F", 
        "greenyellow", "#00CD00", "green3", "#48D1CC", "mediumturquoise", 
        "#007FFF", "blue"), space="Lab", bias=0.5)(n))
}
base <- function(type) {
  map_attr = "© <a href='https://www.esri.com/en-us/home'>ESRI</a> © <a href='https://www.google.com/maps/'>Google</a>"
  leaflet() |>
  addTiles(urlTemplate = "http://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}&s=Ga",
          group  =  "Google") |>
  addProviderTiles("CartoDB.Positron", group = "CartoDB") |>
  addProviderTiles("OpenStreetMap", group = "Open Street Map") |>
  addProviderTiles('Esri.WorldImagery', group = "ESRI") |>
  addTiles(urlTemplate = "", attribution = map_attr) |>
  addLayersControl(
    baseGroups = c("ESRI", "Open Street Map", "CartoDB", "Google"),
    options = layersControlOptions(collapsed = FALSE)) |>
  setView(-110, 60, 4)

}
lfun <- function(map, url, type="viridis", opacity=0.8) {
  leafem::addGeotiff(map,
      url = url,
      project = FALSE,
      opacity = opacity,
      autozoom = FALSE,
      layerId = "raster",
      colorOptions = colorOptions(
        palette = get_pal(50, type), 
        na.color = "transparent"))
}

## ------------- lookup for selections and map urls ---------------

x <- read_with(readRDS, "https://wbi.predictiveecology.org/api/v1/public/wbi/maps-lonlat-with-stats.rds")
Elements <- read.csv("https://raw.githubusercontent.com/PredictiveEcology/wbi_shiny/wbi-full-extent/02-data-proc/wbi/element-lookup.csv")
Values <- list(
  region = list(
    "Full Extent" = "full-extent",
    "Alberta" = "ab",
    "British Columbia" = "bc", 
    "Manitoba" = "mb", 
    "Northwest Territories" = "nt", 
    "Saskatchewan" = "sk", 
    "Yukon Territory" = "yt"),
  scenario = list(
    "CNRM-ESM2-1 SSP370" = "cnrm-esm2-1-ssp370", 
    "CanESM5 SSP370" = "canesm5-ssp370", 
    "CNRM-ESM2-1 SSP585" = "cnrm-esm2-1-ssp585", 
    "CanESM5 SSP585" = "canesm5-ssp585"),
  year20 = c(2011, 2031, 2051, 2071, 2091),
  year10 = c(2011, 2021, 2031, 2041, 2051, 2061, 2071, 2081, 2091, 2100),
  elements = structure(Elements$species_code, names=Elements$common_name))

# url <- "https://wbi.predictiveecology.org/api/v1/public/wbi/full-extent/elements/tree-popu-tre/canesm5-ssp370/2011/lonlat/mean.tif"
# url <- "https://wbi.predictiveecology.org/api/v1/public/wbi/full-extent/elements/bird-alfl/canesm5-ssp370/2011/lonlat/mean.tif"
# rt <- terra::rast(url)
# plot(rt)
# m <- base() |> lfun(url)

## ------------- Shiny App ------------------

shinyApp(
    ui=fluidPage(
        titlePanel("WBI GeoTIF Explorer"),
        sidebarLayout(
        sidebarPanel(width=3,
            sliderInput("opacity", label = "Opacity:", 
            min = 0, value = 0.8, max = 1),
            selectInput("type", "Color palette:", 
            c("spectral", "viridis", "rdylbu", "bam")),
            selectInput("region", "Region:", Values$region),
            selectInput("scenario", "Scenario:", Values$scenario),
            selectInput("element", "Element:", Values$elements),
            uiOutput("ui_yrs")
        ),
        mainPanel(width=9,
            leafletOutput("map", width = "100%", height = 600)
        )
        )
    ),
    server=function(input, output) {
        observeEvent(input$element, {
            y <- sort(unique(x$period[x$element == input$element]))
            output$ui_yrs <- renderUI(selectInput("years", "Time period:", y))
        })
        url <- reactive({
            make_name(
                root="https://wbi.predictiveecology.org",
                api_ver="api/v1",
                access="public",
                project="wbi",
                region=input$region,
                kind="elements",
                element=input$element,
                scenario=input$scenario,
                period=input$years,
                resolution="lonlat",
                file="mean.tif")
        })
        output$map <- renderLeaflet({
            URL <- url()
            base() |>
                lfun(URL, input$type, input$opacity) |>
                htmlwidgets::onRender("
                function(el, x) {
                    this.on('baselayerchange', function(e) {
                    e.layer.bringToBack();
                    })
                }
                ")
        })
    }
)

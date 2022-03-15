

# When implementing mapping functionality in Shiny, check out the following 
# discussion on how to use {leafletProxy} to ensure that the entire map is not
# getting re-drawn each time a widget (input) changes:
# https://stackoverflow.com/questions/37433569/changing-leaflet-map-according-to-input-without-redrawing



#' Create Base Map 
#'
#' @description A small function that builds the "base" leaflet map
#'
#' @return A leaflet map object
#'
#' @noRd
#' 
base_map <- function() {
  leaflet() %>%
    addProviderTiles("Esri.WorldImagery") %>%
    setView(-120, 65, 5)
}



#' Add Element to Base Map
#' 
#' @description `add_element()` queries tiles from the WBI database along the 
#'   user-specified `element`, `scenario`, and `period` parameters, and adds 
#'   those tiles to the base leaflet map
#'
#' @param map A leaflet map object
#' @param element The element type (i.e., species) to retrieve from the database
#'   and display in the map
#' @param scenario The scenario type to retrieve from the database and display 
#'   in the map
#' @param period The time period (year) to retrieve from the database and 
#'   display in the map
#' @param opacity Numeric; the level of opacity to apply to the map tiles
#' @param add_legend Logical; should map legend be shown?
#'
#' @return A leaflet map object with overlaid tiles
#' 
#' @noRd
#' 
#' @examples
#' # Display the "LandR SCFM V4" scenario for the American Robin in year 2011
#' add_element(
#'   map = base_map(), 
#'   element = "American Robin", 
#'   scenario = "LandR SCFM V4", 
#'   period = 2011
#' )
#' 
#' # Use the predicted year 2100 scenario, increase the default opacity, and
#' # hide the legend
#' base_map() |> 
#'   add_element(
#'     element = "American Robin", 
#'     scenario = "LandR SCFM V4", 
#'     period = 2100, 
#'     opacity = 0.7, 
#'     add_legend = FALSE
#'   )
#' 
# need to implement max values for scaling
# need to implement measurement units for title
add_element <- function(map, element, scenario, period, 
                        opacity = 0.8, add_legend = TRUE) {
  
  # Retrieve the appropriate tiles for the element/scenario/period from the 
  # database
  tiles <- sprintf(
    "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/%s/%s/%s/tiles/{z}/{x}/{-y}.png", 
    element, 
    scenario, 
    as.character(period)
  )
  
  # Add the tiles to the base map
  m <- map %>%
    addProviderTiles("Esri.WorldImagery") %>%
    addTiles(
      urlTemplate = tiles,
      options = tileOptions(opacity = opacity)
    )
  
  # If `add_legend = TRUE`, show the legend
  if (add_legend) {
    
    max <- 1   # maximum abundance
    title <- "Abundance"   # title for the legend
    
    # add legend to the leaflet object
    m <- m %>%
      addLegend(
        position = "bottomleft", 
        pal = colorNumeric(
          palette = viridis::viridis_pal(option = "D")(25),
          domain = c(0, max)   # adjust max here too
        ), 
        values = c(0, max), # need to adjust max here
        title = title,
        opacity = 1   # opacity of the legend itself
      )
  }
  
  return(m)
  
}



#' Create Side-by-Side Base Map
#'
#' @description `base_map2x()` creates *side-by-side* base leaflet maps
#'
#' @return A leaflet map object containing two maps side-by-side
#' 
#' @noRd
#'
base_map2x <- function() {
  leaflet() %>%
    addMapPane(name = "left", zIndex = 0) %>%
    addMapPane(name = "right", zIndex = 0) %>%
    addProviderTiles(
      provider = "Esri.WorldImagery", 
      group = "carto_left", 
      options = tileOptions(pane = "left"),
      layerId = "leftid"
    ) %>%
    addProviderTiles(
      provider = "Esri.WorldImagery", 
      group = "carto_right", 
      options = tileOptions(pane = "right"), 
      layerId = "rightid"
    ) %>%
    addSidebyside(
      layerId = "sidecontrols",
      leftId = "leftid",
      rightId = "rightid"
    ) %>%
    setView(-120, 65, 5)
}



#' Add Element to Side-by-Side Map
#' 
#' @description `add_element2x()` queries tiles from the WBI database along the 
#'   user-specified `element`, `scenario`, and `period` parameters, and adds 
#'   those tiles to the base leaflet map
#'
#' @param map A side-by-side leaflet map object
#' @param element The element type (i.e., species) to retrieve from the database
#'   and display in the map
#' @param by How should the side-by-side comparison be defined? Either "scenario" 
#'   or "period"
#' @param opacity Numeric; the level of opacity to apply to the map tiles
#' @param add_legend Logical; should map legend be shown?
#'
#' @return A leaflet map object containing two maps side-by-side with overlaid
#'   tiles
#' 
#' @noRd
#'
#' @examples
#' # Display the side-by-side comparison of both scenarios for the American Robin
#' add_element2x(
#'   map = base_map2x(), 
#'   element = "American Robin", 
#'   by = "scenario"
#' )
#' 
#' # Display the side-by-side comparison of both periods for the American Robin, 
#' # increase the default opacity, and hide the legend
#' base_map2x() |> 
#'   add_element2x(
#'     element = "American Robin", 
#'     by = "period", 
#'     period = 2100, 
#'     opacity = 0.7, 
#'     add_legend = FALSE
#'   )
#' 
add_element2x <- function(map, element, by, opacity = 0.8, add_legend = TRUE) {
  
  # Build the path to the pre-processed tiles
  if (by == "scenario") {
    
    id1 <- "LandR SCFM V4"
    id2 <- "LandR.CS FS V6a"
    
    tiles1 <- paste0(
      "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/",
      element, 
      "/landr-scfm-v4/2100/tiles/{z}/{x}/{-y}.png"
    )
    
    tiles2 <- paste0(
      "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/",
      element, 
      "/landrcs-fs-v6a/2100/tiles/{z}/{x}/{-y}.png"
    )
    
  } else {
    
    id1 <- "2011"
    id2 <- "2100"
    
    tiles1 <- paste0(
      "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/",
      element, 
      "/landrcs-fs-v6a/2011/tiles/{z}/{x}/{-y}.png"
    )
    
    tiles2 <- paste0(
      "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/",
      element, 
      "/landrcs-fs-v6a/2100/tiles/{z}/{x}/{-y}.png"
    )
    
  }
  
  # Add tiles to the map
  m <- map %>%
    addTiles(
      urlTemplate = tiles1, 
      group = id1, 
      layerId = paste0(id1, "_id"),
      options = tileOptions(pane = "left", opacity = opacity)
    ) %>% 
    addTiles(
      urlTemplate = tiles2, 
      group = id2, 
      layerId = paste0(id2, "_id"),
      options = tileOptions(pane = "right", opacity = opacity)
    ) %>% 
    addLayersControl(overlayGroups = c(id1, id2))
  
  # If `add_legend = TRUE`, include legend on map
  if (add_legend) {
    
    max1 <- 1
    max2 <- 1
    
    m <- m %>%
      addLegend(
        position = "bottomleft", 
        pal = colorNumeric(
          palette = viridis::viridis_pal(option = "D")(25),
          domain = c(0, max1)), # adjust max here too
        values = c(0, max1), # need to adjust max here
        title = id1,
        group = id1, 
        layerId = paste0(id1, "_id"),
        opacity = 1
      ) %>%
      addLegend(
        position = "bottomright", 
        pal = colorNumeric(
          palette = viridis::viridis_pal(option = "D")(25),
          domain = c(0, max2)), # adjust max here too
        values = c(0, max2), # need to adjust max here
        title = id2,
        group = id2, 
        layerId = paste0(id2, "_id"),
        opacity = 1
      )
    
  }
  
  return(m)
  
}

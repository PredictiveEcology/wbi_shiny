

# When implementing mapping functionality in Shiny, check out the following 
# discussion on how to use {leafletProxy} to ensure that the entire map is not
# getting re-drawn each time a widget (input) changes:
# https://stackoverflow.com/questions/37433569/changing-leaflet-map-according-to-input-without-redrawing



#' Create Base Map 
#'
#' @description A small function that builds the "base" leaflet map, with the 
#'   ability to choose the map provider (ESRI, Google, CartoDB, Open Street Map)
#'   via a floating widget containing radio buttons for each provider
#'
#' @return A leaflet map object
#'
#' @noRd
#' 
base_map <- function() {
  
  map_attr = "© <a href='https://www.esri.com/en-us/home'>ESRI</a> © <a href='https://www.google.com/maps/'>Google</a>"
  
  leaflet::leaflet() |> 
    leaflet::addTiles(
      urlTemplate = "http://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}&s=Ga",
      group = "Google",
      options = leaflet::providerTileOptions(
        zIndex = 200
      )
    ) |> 
    leaflet::addProviderTiles(
      provider = "CartoDB.Positron", 
      group = "CartoDB",
      options = leaflet::providerTileOptions(
        zIndex = 200
      )
    ) |> 
    leaflet::addProviderTiles(
      provider = "OpenStreetMap", 
      group = "Open Street Map",
      options = leaflet::providerTileOptions(
        zIndex = 200
      )
    ) |> 
    leaflet::addProviderTiles(
      provider = 'Esri.WorldImagery', 
      group = "ESRI",
      options = leaflet::providerTileOptions(
        zIndex = 200
      )
    ) |> 
    leaflet::addTiles(
      urlTemplate = "", 
      attribution = map_attr
    ) |> 
    leaflet::addLayersControl(
      baseGroups = c("ESRI", "Open Street Map", "CartoDB", "Google"), 
      position = "topleft", 
      options = leaflet::layersControlOptions(collapsed = FALSE)) |> 
    leaflet::setView(-120, 65, 5)
  
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
#' @param max Numeric; a positive value to be set as the maximum of the legend.
#' @param pal_max Integer between 1L and 101L; the max range of the color palette.
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
                        opacity = 0.8, add_legend = TRUE,
                        max = 1, pal_max = 101L) {
  
  use_tiff <- get_golem_config("app_geotiff")

  # Retrieve the appropriate tiles for the element/scenario/period from the 
  # database
  pattern <- if (use_tiff) {
    "api/v1/public/wbi-nwt/elements/%s/%s/%s/lonlat/mean.tif"
  } else {
    "api/v1/public/wbi-nwt/elements/%s/%s/%s/tiles/{z}/{x}/{-y}.png"
  }
  tiles <- sprintf(
    paste0(get_golem_config("app_baseurl"), pattern), 
    element, 
    scenario, 
    as.character(period)
  )
  
  # Add the tiles to the base map
  if (use_tiff) {
    m <- map |>
      leafem::addGeotiff(
        url = tiles,
        project = FALSE,
        opacity = opacity,
        autozoom = FALSE,
        layerId = "raster",
        options = leaflet::tileOptions(
          maxNativeZoom = 10,
          zIndex = 400),
        colorOptions = leafem::colorOptions(
          palette = grDevices::hcl.colors(101, "spectral", rev = TRUE)[seq_len(pal_max)],
          domain = c(0, max),
          na.color = "transparent"))
  } else {
    m <- map |>
      leaflet::addTiles(
        urlTemplate = tiles,
        options = leaflet::tileOptions(
          maxNativeZoom = 10,
          opacity = opacity,
          zIndex = 400
        )
      )
  }
  
  # If `add_legend = TRUE`, show the legend
  if (add_legend) {
    
    title <- "Abundance"   # title for the legend
    
    # add legend to the leaflet object
    m <- m |>
      leaflet::addLegend(
        position = "bottomleft", 
        pal = leaflet::colorNumeric(
          palette = grDevices::hcl.colors(101, "spectral", rev = TRUE)[seq_len(pal_max)],
          domain = c(0, max)   # adjust max here too
        ), 
        values = c(0, max), # need to adjust max here
        title = title,
        opacity = opacity
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
  leaflet::leaflet() |>
    leaflet::addMapPane(name = "left", zIndex = 0) |>
    leaflet::addMapPane(name = "right", zIndex = 0) |>
    leaflet::addProviderTiles(
      provider = "Esri.WorldImagery", 
      group = "carto_left", 
      options = leaflet::tileOptions(pane = "left"),
      layerId = "leftid"
    ) |>
    leaflet::addProviderTiles(
      provider = "Esri.WorldImagery", 
      group = "carto_right", 
      options = leaflet::tileOptions(pane = "right"), 
      layerId = "rightid"
    ) |>
    leaflet.extras2::addSidebyside(
      layerId = "sidecontrols",
      leftId = "leftid",
      rightId = "rightid"
    ) |>
    leaflet::setView(-120, 65, 5)
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
#' @param max1,max2 Numeric; a positive value to be set as the maximum of the legend.
#' @param pal_max1,pal_max2 Integer between 1L and 101L; the max range of the color palette.
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
add_element2x <- function(map, element, by, opacity = 0.8, add_legend = TRUE,
                          max1 = 1, max2 = 1, pal_max1 = 101L, pal_max2 = 101L) {
  
  use_tiff <- get_golem_config("app_geotiff")

  # Build the path to the pre-processed tiles
  if (by == "scenario") {
    
    id1 <- "LandR SCFM V4"
    id2 <- "LandR.CS FS V6a"
    
    if (!use_tiff) {
      tiles1 <- paste0(
        get_golem_config("app_baseurl"),
        "api/v1/public/wbi-nwt/elements/",
        element, 
        "/landr-scfm-v4/2100/tiles/{z}/{x}/{-y}.png"
      )
      tiles2 <- paste0(
        get_golem_config("app_baseurl"),
        "api/v1/public/wbi-nwt/elements/",
        element, 
        "/landrcs-fs-v6a/2100/tiles/{z}/{x}/{-y}.png"
      )
    } else {
      tiles1 <- paste0(
        get_golem_config("app_baseurl"),
        "api/v1/public/wbi-nwt/elements/",
        element, 
        "/landr-scfm-v4/2100/lonlat/mean.tif"
      )
      tiles2 <- paste0(
        get_golem_config("app_baseurl"),
        "api/v1/public/wbi-nwt/elements/",
        element, 
        "/landrcs-fs-v6a/2100/lonlat/mean.tif"
      )
    }
    
  } else {
    
    id1 <- "2011"
    id2 <- "2100"
    
    if (!use_tiff) {
      tiles1 <- paste0(
        get_golem_config("app_baseurl"),
        "api/v1/public/wbi-nwt/elements/",
        element, 
        "/landrcs-fs-v6a/2011/tiles/{z}/{x}/{-y}.png"
      )
      tiles2 <- paste0(
        get_golem_config("app_baseurl"),
        "api/v1/public/wbi-nwt/elements/",
        element, 
        "/landrcs-fs-v6a/2100/tiles/{z}/{x}/{-y}.png"
      )
    } else {
      tiles1 <- paste0(
        get_golem_config("app_baseurl"),
        "api/v1/public/wbi-nwt/elements/",
        element, 
        "/landrcs-fs-v6a/2011/lonlat/mean.tif"
      )
      tiles2 <- paste0(
        get_golem_config("app_baseurl"),
        "api/v1/public/wbi-nwt/elements/",
        element, 
        "/landrcs-fs-v6a/2100/lonlat/mean.tif"
      )
    }

  }
  
  # Add tiles to the map
  if (!use_tiff) {
    m <- map |>
      leaflet::addTiles(
        urlTemplate = tiles1, 
        group = id1, 
        layerId = paste0(id1, "_id"),
        options = leaflet::tileOptions(pane = "left", opacity = opacity, maxNativeZoom = 10)
      ) |> 
      leaflet::addTiles(
        urlTemplate = tiles2, 
        group = id2, 
        layerId = paste0(id2, "_id"),
        options = leaflet::tileOptions(pane = "right", opacity = opacity, maxNativeZoom = 10)
      )
  } else {
    m <- map |>
      leafem::addGeotiff(
        url = tiles1,
        project = FALSE,
        opacity = opacity,
        autozoom = FALSE,
        group = id1, 
        layerId = paste0(id1, "_id"),
        options = leaflet::tileOptions(
          pane = "left",
          maxNativeZoom = 10,
          zIndex = 400),
        colorOptions = leafem::colorOptions(
          palette = grDevices::hcl.colors(101, "spectral", rev = TRUE)[seq_len(pal_max1)],
          domain = c(0, max1),
          na.color = "transparent")
      ) |>
      leafem::addGeotiff(
        url = tiles2,
        project = FALSE,
        opacity = opacity,
        autozoom = FALSE,
        group = id2, 
        layerId = paste0(id2, "_id"),
        options = leaflet::tileOptions(
          pane = "right",
          maxNativeZoom = 10,
          zIndex = 400),
        colorOptions = leafem::colorOptions(
          palette = grDevices::hcl.colors(101, "spectral", rev = TRUE)[seq_len(pal_max2)],
          domain = c(0, max2),
          na.color = "transparent")
      )
  }


  # If `add_legend = TRUE`, include legend on map
  if (add_legend) {
    
    m <- m |>
      leaflet::addLegend(
        position = "bottomleft", 
        pal = leaflet::colorNumeric(
          palette = grDevices::hcl.colors(101, "spectral", rev = TRUE)[seq_len(pal_max1)],
          domain = c(0, max1)), # adjust max here too
        values = c(0, max1), # need to adjust max here
        title = id1,
        group = id1, 
        layerId = paste0(id1, "_id"),
        opacity = opacity
      ) |>
      leaflet::addLegend(
        position = "bottomright", 
        pal = leaflet::colorNumeric(
          palette = grDevices::hcl.colors(101, "spectral", rev = TRUE)[seq_len(pal_max2)],
          domain = c(0, max2)), # adjust max here too
        values = c(0, max2), # need to adjust max here
        title = id2,
        group = id2, 
        layerId = paste0(id2, "_id"),
        opacity = opacity
      )
    
  }
  
  return(m)
  
}


#' Small map for regions
#'
#' @param region Character; region to show.
#' @param base Logical; use {base} graphics or {ggplot2}.
#'
#' @return `NULL` invisibly, produces a plot as a side effect.
#' 
#' @noRd
#'
#' @examples
#' map_region(region = "Ecoregions: 50")
map_region <- function(region, base=FALSE) {
  
  if (base) {

    # Build the base map
    plot(STATS$regions["NWT: Northwest Territories", "geom"])
    
    # Color the region on the map
    plot(
      STATS$regions[region, "geom"], 
      col = "gold", 
      border = "tomato", 
      add = TRUE
    )

  } else {

    p <- ggplot2::ggplot(
        data = STATS$regions["NWT: Northwest Territories",]
      ) + 
      ggplot2::geom_sf(
        col="grey", 
        fill="grey"
      ) +
      ggplot2::geom_sf(
        data = STATS$regions[region,], 
        fill = "gold"
      ) +
      ggplot2::theme_minimal()
    print(p)

  }
  
  invisible(NULL)
  
}

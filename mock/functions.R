
## use proxy: https://stackoverflow.com/questions/37433569/changing-leaflet-map-according-to-input-without-redrawing

base_map <- function() {
    leaflet() %>%
    addProviderTiles("Esri.WorldImagery") %>%
    setView(-120, 65, 5)
}

## need to implement max values for scaling
## need to implement measurement units for title
add_element <- function(map, element, scenario, period, opacity = 0.8, add_legend=TRUE) {
    tiles <- sprintf(
        "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/%s/%s/%s/tiles/{z}/{x}/{-y}.png", 
        element, scenario, as.character(period))
    m <- map %>%
        addProviderTiles("Esri.WorldImagery") %>%
        addTiles(
            urlTemplate = tiles,
            options = tileOptions(opacity = opacity))
    if (add_legend) {
        Max <- 1
        Title <- "Abundance"
        m <- m %>%
            addLegend("bottomleft", 
                pal = colorNumeric(
                    palette = viridis::viridis_pal(option = "D")(25),
                    domain = c(0, Max)), # adjust max here too
                values = c(0, Max), # need to adjust max here
                title = Title,
                opacity = 1)
    }
    m
}
#base_map() %>% add_element("bird-amro", "landr-scfm-v4", "2011")


base_map2x <- function() {
    leaflet() %>%
    addMapPane("left", zIndex = 0) %>%
    addMapPane("right", zIndex = 0) %>%
    addProviderTiles("Esri.WorldImagery", 
        group = "carto_left", 
        options = tileOptions(pane = "left"),
        layerId = "leftid") %>%
    addProviderTiles("Esri.WorldImagery", 
        group = "carto_right", 
        options = tileOptions(pane = "right"), 
        layerId = "rightid") %>%
    addSidebyside(layerId = "sidecontrols",
                    leftId = "leftid",
                    rightId = "rightid") %>%
    setView(-120, 65, 5)
}

add_element2x <- function(map, element, by=c("scenario", "period"), 
    opacity = 0.8, add_legend=TRUE) {

    by <- match.arg(by)
    if (by == "scenario") {
        id1 <- "LandR SCFM V4" # ="landr-scfm-v4",
        id2 <- "LandR.CS FS V6a"#="landrcs-fs-v6a")
        tiles1 <- paste0("https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/",
            element, "/landr-scfm-v4/2100/tiles/{z}/{x}/{-y}.png")
        tiles2 <- paste0("https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/",
            element, "/landrcs-fs-v6a/2100/tiles/{z}/{x}/{-y}.png")
    } else {
        id1 <- "2011" # ="landr-scfm-v4",
        id2 <- "2100"#="landrcs-fs-v6a")
        tiles1 <- paste0("https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/",
            element, "/landrcs-fs-v6a/2011/tiles/{z}/{x}/{-y}.png")
        tiles2 <- paste0("https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/",
            element, "/landrcs-fs-v6a/2100/tiles/{z}/{x}/{-y}.png")
    }
    m <- map %>%
        addTiles(
            urlTemplate = tiles1, 
            group = id1, 
            layerId = paste0(id1, "_id"),
            options = tileOptions(pane="left", opacity = opacity)) %>% 
        addTiles(
            urlTemplate = tiles2, 
            group = id2, 
            layerId = paste0(id2, "_id"),
            options = tileOptions(pane="right", opacity = opacity)) %>% 
        addLayersControl(overlayGroups = c(id1, id2))
    if (add_legend) {
        Max1 <- 1
        Max2 <- 1
        m <- m %>%
            addLegend("bottomleft", 
                pal = colorNumeric(
                    palette = viridis::viridis_pal(option = "D")(25),
                    domain = c(0, Max1)), # adjust max here too
                values = c(0, Max1), # need to adjust max here
                title = id1,
                group = id1, 
                layerId = paste0(id1, "_id"),
                opacity = 1) %>%
            addLegend("bottomright", 
                pal = colorNumeric(
                    palette = viridis::viridis_pal(option = "D")(25),
                    domain = c(0, Max2)), # adjust max here too
                values = c(0, Max2), # need to adjust max here
                title = id2,
                group = id2, 
                layerId = paste0(id2, "_id"),
                opacity = 1)
    }
    m
}
#base_map2x() %>% add_element2x("bird-amro", "scenario")


assets_table <- function(x) {
    reactable(
        x,
        rownames = FALSE,
        filterable = TRUE,
        highlight = TRUE,
        showPageSizeOptions = TRUE,
        columns = list(
            group = colDef(name = "Group"),
            species_code = colDef(name = "Species Code"),
            common_name = colDef(name = "Common Name"),
            scientific_name = colDef(name = "Scientific Name"),
            scenario = colDef(name = "Scenario"),
            period = colDef(name = "Period"),
            resolution = colDef(name = "Resolution"),
            path = colDef(name = "Link", align = "left", sortable = FALSE,
                html = TRUE, cell = function(value, index) {
                sprintf('<a href="%s" target="_blank">%s</a>', 
                paste0("https://wbi-nwt.analythium.app/", LINKS$path[index]), "Link")
            })
        ),
        theme = reactableTheme(
            borderColor = "#dfe2e5",
            stripedColor = "#f6f8fa",
            highlightColor = "#f0f5f9",
            cellPadding = "8px 12px",
            searchInputStyle = list(width = "100%"),
            rowSelectedStyle = list(backgroundColor = "#eee",
                                    boxShadow = "inset 2px 0 0 0 #69B34C")
        )
    )
}

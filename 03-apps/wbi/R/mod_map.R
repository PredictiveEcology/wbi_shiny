#' map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_map_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    div(
      class = "outer", 
      
      # Map ----
      leaflet::leafletOutput(
        outputId = ns("map"), 
        width = "100%", 
        height = "100%"
      ), 
      
      # Panel ----
      absolutePanel(
        id = "controls", 
        class = "panel panel-default", 
        fixed = TRUE,
        draggable = TRUE, 
        top = 80, 
        left = "auto", 
        right = 20, 
        bottom = "auto",
        width = 330, 
        height = "auto", 
        
        shiny::br(),
        
        shinyWidgets::pickerInput(
          inputId = ns("map_element"),
          label = "Species Name:", 
          choices = ELEMENT_NAMES, 
          selected = ELEMENT_NAMES$bird[[1]], 
          options = list(
            `live-search` = TRUE
            # style = "border-color: #999999;"
            # style = paste0(
            #   "background-color: white; ",
            #   "border-color: #999999; ",
            #   "font-family: 'Helvetica Neue' Helvetica; ",
            #   "font-weight: 200;"
            # )
          )
        ),
        
        selectInput(
          inputId = ns("map_scenario"),
          label = "Scenario:",
          choices = SCENARIOS,
          selected = SCENARIOS[[1]]
        ),
        
        selectInput(
          inputId = ns("map_period"), 
          label = "Time Period:", 
          choices = get_period_choices(
            ELEMENTS[ELEMENTS$species_code == ELEMENT_NAMES$bird[[1]], ]
          ),
          selected = ELEMENTS[ELEMENTS$species_code == ELEMENT_NAMES$bird[[1]], "year_start"]
        ),
        
        shiny::actionButton(
          inputId = ns("edit_map_settings"),
          label = "Change Preferences",
          icon = shiny::icon("gear")
        )
        
      )
      
    )
    
  )
}

#' map Server Functions
#'
#' @noRd 
mod_map_server <- function(id, elements){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    ## Set Initial Filter Selections ----
    # Create a `reactiveValues` list to hold current selections for each filter
    # in the modal; this will help make user choices redundant when re-launching
    # the modal.
    # Start by setting some defaults that will appear the first time the modal
    # is launched
    current_selections <- shiny::reactiveValues(
      region = REGIONS[[1]],
      palette = "spectral",
      opacity = 0.8
    )
    
    ## Modal ----
    # Create modal to hold all input widgets / filters
    shiny::observeEvent(input$edit_map_settings, {
      
      modal <- shiny::modalDialog(
        
        title = "Set Map Preferences",
        
        selectInput(
          inputId = ns("map_region"),
          label = "Region:", 
          choices = REGIONS,
          selected = current_selections$region
        ),
        
        selectInput(
          inputId = ns("map_palette"), 
          label = "Color Palette:", 
          choices = c(
            "Spectral" = "spectral", 
            "Viridis" = "viridis", 
            "Red Yellow Blue" = "rdylbu", 
            "BAM" = "bam"),
          selected = current_selections$palette
        ),
        
        sliderInput(
          inputId = ns("map_opacity"), 
          label = "Opacity:", 
          min = 0, 
          max = 1, 
          value = current_selections$opacity
        ),
        
        footer = shiny::actionButton(
          inputId = ns("close_modal"), 
          label = "Apply"
        ),
        
        size = "s"
        
      )
      
      shiny::showModal(modal)
      
    })
    
    # Update "Period" choices when Species changes
    shiny::observeEvent(input$map_element, {
      
      # ... update the choices in the "Period" dropdown filter list
      updateSelectInput(
        session = session, 
        inputId = "map_period", 
        choices = get_period_choices(
          ELEMENTS[ELEMENTS$species_code == input$map_element, ]
        )
      )
      
    })
    
    # When the "Apply" button is clicked in the modal, capture the inputs to
    # apply when the modal is re-launched
    shiny::observeEvent(input$close_modal, {
      
      current_selections$region <- input$map_region
      current_selections$palette <- input$map_palette
      current_selections$opacity <- input$map_opacity
      
      shiny::removeModal(session = session)
      
    })
    
    # Create the reactive URL to the tif files on the API server
    url <- shiny::reactive({
      
      make_api_path(
        root  =  paste0(get_golem_config("app_baseurl"), "api"), 
        api_ver = "1", 
        access = "public", 
        project = "wbi", 
        region = current_selections$region,
        kind = "elements",
        element = input$map_element,
        scenario = input$map_scenario,
        period = input$map_period,
        resolution = "lonlat",
        file = "mean.tif"
      )
      
    })
    
    # Map ----
    output$map <- leaflet::renderLeaflet({
      
      legend_max <- MAPSTATS[
        MAPSTATS$region == current_selections$region &
          MAPSTATS$element == input$map_element &
          MAPSTATS$scenario == input$map_scenario &
          MAPSTATS$period == input$map_period,
        "max"
      ]
      
      base_map() |> 
        add_element(
          url = url(),
          palette_length = 50L,
          palette_type = current_selections$palette,
          max = legend_max
        ) |> 
        leaflet::addMeasure(
          position = "topleft"
        ) |>
        htmlwidgets::onRender("
          function(el, x) {
            this.on('baselayerchange', function(e) {
              e.layer.bringToBack();
            })
          }
        ")
      
    })
    
  })
}

## To be copied in the UI
# mod_map_ui("map_ui_1")

## To be copied in the server
# mod_map_server("map_ui_1")

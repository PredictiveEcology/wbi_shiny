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
        
        build_accordion(
          id = "map",
          header = "You are now viewing:",
          content = shiny::tags$ul(
            
            shiny::tags$li(
              shiny::span(
                "Region: ",
                shiny::textOutput(
                  outputId = ns("region_text"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            ),
            
            shiny::tags$li(
              shiny::span(
                "Species Group: ", 
                shiny::textOutput(
                  outputId = ns("species_group_text"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            ),
            
            shiny::tags$li(
              shiny::span(
                "Species Name: ", 
                shiny::textOutput(
                  outputId = ns("species_name_text"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            ),
            
            shiny::tags$li(
              shiny::span(
                "Scenario: ", 
                shiny::textOutput(
                  outputId = ns("scenario_text"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            ),
            
            shiny::tags$li(
              shiny::span(
                "Time Period: ", 
                shiny::textOutput(
                  outputId = ns("period_text"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            )
            
          )
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
    # Create a `reactiveValues` list to hold current selections for each filter;
    # This will help make user choices redundant when re-launching the modal;
    # Start by setting some defaults that will appear the first time the modal
    # is launched
    current_selections <- shiny::reactiveValues(
      region = REGIONS[[1]],
      element_type = "bird",
      element_choices = ELEMENT_NAMES$bird,
      element = ELEMENT_NAMES$bird[[1]],
      scenario = SCENARIOS[[1]],
      period = ELEMENTS[ELEMENTS$species_code == ELEMENT_NAMES$bird[[1]], "year_start"],
      period_choices = get_period_choices(
        ELEMENTS[ELEMENTS$species_code == ELEMENT_NAMES$bird[[1]], ]
      ),
      palette = "viridis",
      opacity = 0.8,
      element_display = ELEMENT_NAMES$bird[[1]]
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
        
        shinyWidgets::pickerInput(
          inputId = ns("map_element"),
          label = "Species Name:", 
          choices = ELEMENT_NAMES, 
          selected = current_selections$element, 
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
          selected = current_selections$scenario
        ),
        
        selectInput(
          inputId = ns("map_period"), 
          label = "Time Period:", 
          choices = current_selections$period_choices,
          selected = current_selections$period
        ), 
        
        selectInput(
          inputId = ns("map_palette"), 
          label = "Color Palette:", 
          choices = c("bam", "rdylbu", "spectral", "viridis"),
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
      
      shiny::req(
        current_selections$element,
        input$map_element
      )
      
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
      current_selections$element <- input$map_element
      current_selections$scenario <- input$map_scenario
      current_selections$period <- input$map_period
      current_selections$period_choices <- get_period_choices(
        ELEMENTS[ELEMENTS$species_code == input$map_element, ]
      )
      current_selections$palette <- input$map_palette
      current_selections$opacity <- input$map_opacity
      
      current_selections$element_type <- lookup_element_type_by_value(
        x = ELEMENT_NAMES, 
        value = input$map_element
      )
      current_selections$element_choices <- ELEMENT_NAMES[[current_selections$element_type]]
      current_selections$element_display <- current_selections$element
      
      shiny::removeModal(session = session)
      
    })
    
    # Create the reactive URL to the tif files on the API server
    url <- shiny::reactive({
      
      make_api_path(
        root  =  "https://wbi.predictiveecology.org/api", 
        api_ver = "1", 
        access = "public", 
        project = "wbi", 
        region = current_selections$region,
        kind = "elements",
        element = current_selections$element,
        scenario = current_selections$scenario,
        period = current_selections$period,
        resolution = "lonlat",
        file = "mean.tif"
      )
      
    })
    
    # Map ----
    output$map <- leaflet::renderLeaflet({
      
      legend_max <- MAPSTATS[
        MAPSTATS$region == current_selections$region &
          MAPSTATS$element == current_selections$element &
          MAPSTATS$scenario == current_selections$scenario &
          MAPSTATS$period == current_selections$period,
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
    
    # Summary Text ----
    
    # Render "Region" selection text
    output$region_text <- shiny::renderText(
      
      lookup_element_name_by_value(
        x = REGIONS,
        value = current_selections$region
      )
      
    )
    
    # Render "Species Group" selection text
    output$species_group_text <- shiny::renderText(
      
      current_selections$element_type |> 
        tools::toTitleCase()
      
    )
    
    # Render "Species Name" selection text
    output$species_name_text <- shiny::renderText({
      
      shiny::req(
        current_selections$element_type,
        current_selections$element_display
      )
      
      lookup_element_name_by_value(
        x = ELEMENT_NAMES[[current_selections$element_type]],
        value = current_selections$element_display
      )
      
    })
    
    # Render "Scenario" selection text
    output$scenario_text <- shiny::renderText({
      
      lookup_element_name_by_value(
        x = SCENARIOS,
        value = current_selections$scenario
      )
      
    })
    
    # Render "Period" selection text
    output$period_text <- shiny::renderText(current_selections$period)
    
  })
}

## To be copied in the UI
# mod_map_ui("map_ui_1")

## To be copied in the server
# mod_map_server("map_ui_1")

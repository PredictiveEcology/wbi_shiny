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
      
      leaflet::leafletOutput(
        outputId = ns("map"), 
        width = "100%", 
        height = "100%"
      ), 
      
      absolutePanel(
        id = "controls", 
        class = "panel panel-default", 
        fixed = TRUE,
        draggable = TRUE, 
        top = 60, 
        left = "auto", 
        right = 20, 
        bottom = "auto",
        width = 330, 
        height = "auto",
        
        # selectInput(
        #   inputId = "map_element", 
        #   label = "Element name:", 
        #   ELEMENT_NAMES
        # ), 
        # 
        # selectInput(
        #   inputId = "map_scenario", 
        #   label = "Scenario:", 
        #   choices = SCENARIOS
        # ), 
        
        selectInput(
          inputId = ns("map_period"), 
          label = "Time periods:", 
          choices = c(2011, 2100)
        ), 
        
        sliderInput(
          inputId = ns("map_opacity"), 
          label = "Opacity:", 
          min = 0, 
          max = 1, 
          value = 0.8
        )
      )
    )
    
  )
}

#' map Server Functions
#'
#' @noRd 
mod_map_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    output$map <- leaflet::renderLeaflet({
      base_map()
    })
    
  })
}

## To be copied in the UI
# mod_map_ui("map_ui_1")

## To be copied in the server
# mod_map_server("map_ui_1")

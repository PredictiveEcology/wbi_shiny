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
        top = 80, 
        left = "auto", 
        right = 20, 
        bottom = "auto",
        width = 330, 
        height = "auto", 
        
        br(), 
        
        radioButtons(
          inputId = ns("map_element_type"), 
          label = "Species Type:", 
          choices = c("Bird", "Tree"), 
          selected = "Bird", 
          inline = TRUE
        ), 
        
        selectInput(
          inputId = ns("map_element"),
          label = "Species Name:", 
          choices = row.names(ELEMENTS[ELEMENTS$group == "bird", ])
        ),

        selectInput(
          inputId = ns("map_scenario"),
          label = "Scenario:",
          choices = SCENARIOS
        ),
        
        selectInput(
          inputId = ns("map_period"), 
          label = "Time Period:", 
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
mod_map_server <- function(id, elements){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    # Update the options under "Element Name" based upon the selection in the 
    # "Element Type" radio button
    observe({
      
      element_type <- tolower(input$map_element_type)
      
      updateSelectInput(
        session = session, 
        inputId = "map_element", 
        choices = row.names(ELEMENTS[ELEMENTS$group == element_type, ])
      )
      
    })
    
    # Render the map
    output$map <- leaflet::renderLeaflet({
      MS <- MAPSTATS[
        MAPSTATS$element_name == input$map_element & 
        MAPSTATS$scenario == input$map_scenario & 
        MAPSTATS$year == input$map_period,
      ]
      base_map() |> 
        add_element(
          element = input$map_element, 
          scenario = input$map_scenario, 
          period = input$map_period,
          opacity = input$map_opacity,
          max = MS$max, 
          pal_max = MS$pal_max
        ) |> 
        leaflet::addMeasure(
          position = "topleft"
        )
    })
    
  })
}

## To be copied in the UI
# mod_map_ui("map_ui_1")

## To be copied in the server
# mod_map_server("map_ui_1")

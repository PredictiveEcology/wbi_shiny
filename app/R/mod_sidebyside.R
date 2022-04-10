#' sidebyside UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_sidebyside_ui <- function(id){
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
        
        selectInput(
          inputId = ns("by_2x"), 
          label = "Compare By:", 
          choices = c("scenario", "year")
        ), 
        
        radioButtons(
          inputId = ns("map_element_type"), 
          label = "Species Group:", 
          choices = c("Birds" = "bird", "Trees" = "tree"), 
          selected = "bird", 
          inline = TRUE
        ), 
        
        selectInput(
          inputId = ns("map_element"),
          label = "Species Name:", 
          choices = row.names(ELEMENTS[ELEMENTS$group == "bird", ])
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
    
#' sidebyside Server Functions
#'
#' @noRd 
mod_sidebyside_server <- function(id){
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
      if (input$by_2x == "scenario") {
        MS1 <- MAPSTATS[
          MAPSTATS$element_name == input$map_element & 
          MAPSTATS$scenario == "landr-scfm-v4" & 
          MAPSTATS$year == "2100",
        ]
        MS2 <- MAPSTATS[
          MAPSTATS$element_name == input$map_element & 
          MAPSTATS$scenario == "landrcs-fs-v6a" & 
          MAPSTATS$year == "2100",
        ]
      } else {
        MS1 <- MAPSTATS[
          MAPSTATS$element_name == input$map_element & 
          MAPSTATS$scenario == "landrcs-fs-v6a" & 
          MAPSTATS$year == "2011",
        ]
        MS2 <- MAPSTATS[
          MAPSTATS$element_name == input$map_element & 
          MAPSTATS$scenario == "landrcs-fs-v6a" & 
          MAPSTATS$year == "2100",
        ]
      }
      base_map2x() |> 
        add_element2x(
          element = input$map_element, 
          by = input$by_2x,
          opacity = input$map_opacity,
          max1 = MS1$max,
          max2 = MS2$max,
          pal_max1 = MS1$pal_max,
          pal_max2 = MS2$pal_max
        ) |> 
        leaflet::addMeasure(
          position = "topleft"
        )
    })
    
  })
}
    
## To be copied in the UI
# mod_sidebyside_ui("sidebyside_ui_1")
    
## To be copied in the server
# mod_sidebyside_server("sidebyside_ui_1")

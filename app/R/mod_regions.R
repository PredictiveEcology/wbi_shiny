#' regions UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_regions_ui <- function(id){
  ns <- NS(id)
  tagList(
 
    fluidRow(
      
      column(
        width = 3, 
        
        wellPanel(
          
          radioButtons(
            inputId = ns("regions_element_type"), 
            label = "Element Type", 
            choices = c("Bird", "Tree"), 
            selected = "Bird", 
            inline = TRUE
          ), 
          
          selectInput(
            inputId = ns("regions_element"),
            label = "Element Name:", 
            choices = unique(STATS$elements$element[STATS$elements$group == "bird"])
          ),
          
          selectInput(
            inputId = ns("regions_region"),
            label = "Scenario:",
            choices = row.names(STATS$regions)
          )
          
        )
        
      ), 
      
      column(
        width = 9, 
        
        reactable::reactableOutput(outputId = ns("stats_tbl"))
        
      )
      
    )
    
  )
}
    
#' regions Server Functions
#'
#' @noRd 
mod_regions_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
    # Update the options under "Element Name" based upon the selection in the 
    # "Element Type" radio button
    observe({
      
      element_type <- tolower(input$regions_element_type)
      
      updateSelectInput(
        session = session, 
        inputId = "regions_element", 
        choices = unique(STATS$elements$element[STATS$elements$group == element_type])
      )
      
    })
    
    output$stats_tbl <- reactable::renderReactable({
      
      get_stats(
        element = input$regions_element, 
        region = input$regions_region
      ) |> 
        reactable::reactable(
          columns = list(
            Mean = reactable::colDef(
              format = reactable::colFormat(digits = 4)
            )
          )
        )
      
    })
    
  })
}
    
## To be copied in the UI
# mod_regions_ui("regions_ui_1")
    
## To be copied in the server
# mod_regions_server("regions_ui_1")

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
    
    wellPanel(
      style = "padding-bottom: 0rem;", 
      
      fluidRow(
        
        column(
          width = 3, 
          align = "center", 
          
          radioButtons(
            inputId = ns("regions_element_type"), 
            label = "Element Type", 
            choices = c("Bird", "Tree"), 
            selected = "Bird", 
            inline = TRUE
          )
          
        ), 
        
        column(
          width = 4, 
          
          selectInput(
            inputId = ns("regions_element"),
            label = "Element Name:", 
            choices = unique(STATS$elements$element[STATS$elements$group == "bird"])
          )
          
        ), 
        
        column(
          width = 5, 
          
          selectInput(
            inputId = ns("regions_region"),
            label = "Region:",
            choices = row.names(STATS$regions)
          )
          
        )
        
      )
      
    ), 
    
    hr(), 
    
    fluidRow(
      
      column(
        width = 5, 
        
        plotOutput(outputId = ns("regions_map"))
        
      ), 
      
      column(
        width = 7, 
        
        tabsetPanel(
          
          tabPanel(
            title = "Table", 
            
            reactable::reactableOutput(outputId = ns("stats_tbl"))
            
          ), 
          
          tabPanel(
            title = "Chart", 
            
            h1("Placeholder")
            
          )
          
        )
        
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
          
          resizable = TRUE, 
          bordered = TRUE, 
          
          defaultColDef = reactable::colDef(minWidth = 75), 
          
          columns = list(
            
            Index = reactable::colDef(show = FALSE), 
            
            Year = reactable::colDef(minWidth = 50), 
            
            Region = reactable::colDef(minWidth = 200), 
            
            Mean = reactable::colDef(
              format = reactable::colFormat(digits = 4)
            )
            
          )
        )
      
    })
    
    output$regions_map <- renderPlot({
      
      map_region(region = input$regions_region)
      
    })
    
  })
}

## To be copied in the UI
# mod_regions_ui("regions_ui_1")

## To be copied in the server
# mod_regions_server("regions_ui_1")

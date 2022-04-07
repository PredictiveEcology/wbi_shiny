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
            label = "Species Type:", 
            choices = c("Bird", "Tree"), 
            selected = "Bird", 
            inline = TRUE
          )
          
        ), 
        
        column(
          width = 4, 
          
          selectInput(
            inputId = ns("regions_element"),
            label = "Species Name:", 
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
    
    br(), 
    
    fluidRow(
      
      column(
        width = 4, 
        
        plotOutput(
          outputId = ns("regions_map"), 
          height = "375px"
        )
        
      ), 
      
      column(
        width = 8, 
        
        tabsetPanel(
          
          tabPanel(
            title = "Chart", 
            
            echarts4r::echarts4rOutput(
              outputId = ns("regions_trend_chart"), 
              height = "375px"
            )
            
          ), 
          
          tabPanel(
            title = "Table", 
            
            reactable::reactableOutput(
              outputId = ns("regions_stats_tbl"), 
              height = "375px"
            )
            
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
    
    # Capture the current data based upon the user's selections from the 
    # "Element" and "Region" widgets
    regions_data <- reactive({
      
      df <- get_stats(
        element = input$regions_element, 
        region = input$regions_region
      )
      
      df$Mean <- round(df$Mean, 4)   # for formatting in table & chart tooltip
      
      df
      
    })
    
    # Update the options under "Element Name" based upon the selection in the 
    # "Element Type" radio button
    observe({
      
      req(input$regions_element_type)
      
      element_type <- tolower(input$regions_element_type)
      
      updateSelectInput(
        session = session, 
        inputId = "regions_element", 
        choices = unique(STATS$elements$element[STATS$elements$group == element_type])
      )
      
    })
    
    # Render the map visual
    output$regions_map <- renderPlot({
      
      req(input$regions_region)
      
      map_region(region = input$regions_region)
      
    })
    
    # Render the interactive chart 
    output$regions_trend_chart <- echarts4r::renderEcharts4r({
      
      req(regions_data())
      
      plot_trend(data = regions_data())
      
    })
    
    # Render the interactive data table
    output$regions_stats_tbl <- reactable::renderReactable({
      
      req(regions_data())
      
      regions_data() |> 
        reactable::reactable(
          # Specify overall table "default" settings
          resizable = TRUE, 
          bordered = TRUE, 
          defaultColDef = reactable::colDef(minWidth = 75), 
          # Specify individual column settings
          columns = list(
            Index = reactable::colDef(show = FALSE), 
            Element = reactable::colDef(name = "Species Name"), 
            Year = reactable::colDef(minWidth = 50), 
            Region = reactable::colDef(minWidth = 200)
          )
        )
      
    })
    
  })
}

## To be copied in the UI
# mod_regions_ui("regions_ui_1")

## To be copied in the server
# mod_regions_server("regions_ui_1")

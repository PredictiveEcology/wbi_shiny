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
          width = 6, 
          
          shinyWidgets::pickerInput(
            inputId = ns("regions_element"),
            label = "Species Name:", 
            choices = ELEMENT_NAMES, 
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
          )
          
        ), 
        
        column(
          width = 6, 
          
          shinyWidgets::pickerInput(
            inputId = ns("regions_region"),
            label = "Region:", 
            choices = split(STATS$regions$region, STATS$regions$classification), 
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
        choices = ELEMENT_NAMES[[element_type]]
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
          rownames = FALSE,
          resizable = TRUE, 
          bordered = TRUE, 
          defaultColDef = reactable::colDef(minWidth = 75), 
          defaultPageSize = 50,
          # Specify individual column settings
          columns = list(
            Index = reactable::colDef(show = FALSE), 
            Element = reactable::colDef(name = "Species Name", show = FALSE), 
            Year = reactable::colDef(minWidth = 35), 
            Region = reactable::colDef(show = FALSE),
            Mean = reactable::colDef(minWidth = 35)
          )
        )
      
    })
    
  })
}

## To be copied in the UI
# mod_regions_ui("regions_ui_1")

## To be copied in the server
# mod_regions_server("regions_ui_1")

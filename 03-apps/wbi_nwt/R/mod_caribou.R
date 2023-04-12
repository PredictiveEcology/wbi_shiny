#' caribou UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_caribou_ui <- function(id){
  ns <- NS(id)
  tagList(
 
    wellPanel(
      style = "padding-bottom: 0rem;", 
      
      fluidRow(
        
        column(
          width = 5, 
          
          selectInput(
            inputId = ns("caribou_region"),
            label = "Region:",
            choices = row.names(STATS$regions[STATS$regions$classification == "Caribou Meta-herds",])
          )
          
        )
        
      )
      
    ), 
    
    br(), 
    
    fluidRow(
      
      column(
        width = 4, 
        
        plotOutput(
          outputId = ns("caribou_map"), 
          height = "375px"
        )
        
      ), 
      
      column(
        width = 8, 
        
        tabsetPanel(
          
          tabPanel(
            title = "Chart", 
            
            echarts4r::echarts4rOutput(
              outputId = ns("caribou_trend_chart"), 
              height = "375px"
            )
            
          ), 
          
          tabPanel(
            title = "Table", 
            
            reactable::reactableOutput(
              outputId = ns("caribou_stats_tbl"), 
              height = "375px"
            )
            
          )
          
        )
        
      )
      
    )

  )
}
    
#' caribou Server Functions
#'
#' @noRd 
mod_caribou_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
    # Capture the current data based upon the user's selections from the 
    # "Region" widget
    caribou_data <- reactive({

      df <- CARIBOU[CARIBOU$region == input$caribou_region,]
      df$min_lambda <- round(df$min_lambda, 4)
      df$max_lambda <- round(df$max_lambda, 4)
      df$mean_lambda <- round(df$mean_lambda, 4)
      colnames(df) <- c("Region", "Year", "Minimum", "Maximum", "Lambda")
      df

    })
    
    # Render the map visual
    output$caribou_map <- renderPlot({
      
      req(input$caribou_region)
      
      map_region(region = input$caribou_region)
      
    })
    
    # Render the interactive chart 
    output$caribou_trend_chart <- echarts4r::renderEcharts4r({
      
      req(caribou_data())
      
      caribou_data() |> 
        echarts4r::e_charts(Year) |> 
        echarts4r::e_line(
          serie = Lambda, 
          symbol = "circle", 
          symbolSize = 15
        ) |> 
        echarts4r::e_axis_labels(
          x = "Year", 
          y = "Lambda"
        ) |> 
        echarts4r::e_tooltip(trigger = "axis") |>
        echarts4r::e_band(
          min = Minimum,
          max = Maximum)
      
    })
    
    # Render the interactive data table
    output$caribou_stats_tbl <- reactable::renderReactable({
      
      req(caribou_data())
      
      caribou_data()[,-1] |> 
        reactable::reactable(
          # Specify overall table "default" settings
          resizable = TRUE, 
          bordered = TRUE, 
          defaultColDef = reactable::colDef(minWidth = 75)
        )
      
    })

  })
}
    
## To be copied in the UI
# mod_caribou_ui("caribou_ui_1")
    
## To be copied in the server
# mod_caribou_server("caribou_ui_1")

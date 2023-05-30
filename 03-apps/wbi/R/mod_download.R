#' download UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_download_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    shiny::fluidRow(
      shiny::column(
        width = 3, 
        
        shinyWidgets::pickerInput(
          inputId = ns("download_element"),
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
      
      shiny::selectInput(
        inputId = ns("download_region"),
        label = "Region",
        choices = REGIONS
      )
      
    ),
    
    shiny::fluidRow(
      shiny::column(
        width = 12,
        
        build_alert(
          content = shiny::textOutput(
            outputId = ns("alert_text"),
            inline = TRUE
          )
        )
        
      )
    ),
    
    fluidRow(
      column(
        width = 12, 
        
        reactable::reactableOutput(
          outputId = ns("download_tbl")
        )
        
      )
    )
    
  )
}

#' download Server Functions
#'
#' @noRd 
mod_download_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    # # When the selected element changes...
    # alert_text <- shiny::eventReactive(input$download_element, {
    #   
    #   # ... add code to grab the comment we want to include in the alert box
    #   # from some dataset
    #   
    # })

    output$alert_text <- shiny::renderText(
      "NOTE: These results are still preliminary and should be treated as such..."
    )
    
    download_data <- reactive({
      
      shiny::req(
        input$download_element,
        input$download_region
      )
      
      out <- expand.grid(
        element = input$download_element,
        region = input$download_region,
        scenario = unlist(SCENARIOS) |> unname(),
        period = get_period_choices(
          x = ELEMENTS[ELEMENTS$species_code == input$download_element, ]
        )
      )
      
      out$link <- make_api_path(
        root = paste0(get_golem_config("app_baseurl"), "api"),
        region = out$region, 
        element = out$element,
        scenario = out$scenario,
        period = out$period,
        resolution = "lonlat",
        file = "mean.tif"
      )
      
      # TODO // Edit this to remove download links from {reactable} table
      # out$show <- TRUE
      
      out
        
    })
    
    output$download_tbl <- reactable::renderReactable(
      
      download_table(data = download_data())
      
    )
    
  })
}

## To be copied in the UI
# mod_download_ui("download_ui_1")

## To be copied in the server
# mod_download_server("download_ui_1")

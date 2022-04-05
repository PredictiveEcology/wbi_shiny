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
 
    output$download_tbl <- reactable::renderReactable({
      
      download_table(MAIN)
      
    })
    
  })
}
    
## To be copied in the UI
# mod_download_ui("download_ui_1")
    
## To be copied in the server
# mod_download_server("download_ui_1")

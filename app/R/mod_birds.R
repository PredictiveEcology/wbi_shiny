#' birds UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_birds_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' birds Server Functions
#'
#' @noRd 
mod_birds_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_birds_ui("birds_ui_1")
    
## To be copied in the server
# mod_birds_server("birds_ui_1")

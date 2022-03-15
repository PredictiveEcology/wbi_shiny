#' assets UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_assets_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' assets Server Functions
#'
#' @noRd 
mod_assets_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_assets_ui("assets_ui_1")
    
## To be copied in the server
# mod_assets_server("assets_ui_1")

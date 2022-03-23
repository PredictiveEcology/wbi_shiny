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
 
  )
}
    
#' caribou Server Functions
#'
#' @noRd 
mod_caribou_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_caribou_ui("caribou_ui_1")
    
## To be copied in the server
# mod_caribou_server("caribou_ui_1")

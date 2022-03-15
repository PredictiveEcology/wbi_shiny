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
 
  )
}
    
#' regions Server Functions
#'
#' @noRd 
mod_regions_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_regions_ui("regions_ui_1")
    
## To be copied in the server
# mod_regions_server("regions_ui_1")

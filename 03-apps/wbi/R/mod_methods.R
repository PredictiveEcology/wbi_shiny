#' methods UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_methods_ui <- function(id){
  ns <- NS(id)
  tagList(
    h1("Methods"),
    p("Coming soon...")
  )
}
    
#' methods Server Functions
#'
#' @noRd 
mod_methods_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_methods_ui("methods_ui_1")
    
## To be copied in the server
# mod_methods_server("methods_ui_1")

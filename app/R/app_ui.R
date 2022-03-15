#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    
    # Add external resources ----
    golem_add_external_resources(),
    
    # Nav Bar ----
    bslib::page_navbar(
      id = "nav_bar", 
      title = "WBI", 
      bg = "#4E9D28",   # Predictive Ecology Green
      theme = bslib::bs_theme(
        bootswatch = "united",
        bg = "#FFFFFF",
        fg = "#3B2313",   # Predictive Ecology Brown
        primary = "#C4161C",   # Predictive Ecology Red/Orange
        base_font = bslib::font_google("Arvo")
      ), 
      
      # "Map" Page ----
      bslib::nav(
        title = "Map", 
        
        mod_map_ui("map_ui_1")
        
      ), 
      
      # "Side-by-Side" Page ----
      bslib::nav(
        title = "Side-by-Side", 
        
        shiny::p("Placeholder2")
      ), 
      
      # "Regions" Page ----
      bslib::nav(
        title = "Regions", 
        
        shiny::p("Placeholder3")
      ), 
      
      # "Assets" Page ----
      bslib::nav(
        title = "Assets", 
        
        shiny::p("Placeholder4")
      ), 
      
    )
    
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
  
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'ShinyWBI'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}


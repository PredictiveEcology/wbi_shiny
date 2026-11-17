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
      title = span(
        img(src = "www/favicon.ico", height = 30), 
        shiny::a(
          span(
            strong("WBI"),
            style = "color: #E1E375"
          ), # Predictive Ecology Yellow
          href = "https://wbi.predictiveecology.org/", 
          style = "text-decoration: none;"
        )
      ), 
      bg = "#607086", 
      theme = bslib::bs_theme(
        version = 5, 
        bootswatch = "zephyr",
        bg = "#FFFFFF",
        fg = "#000000",   
        primary = "#C4161C",   # Predictive Ecology Red/Orange
        base_font = bslib::font_google("Arvo")
      ), 
      
      # Map Pages: one per group ----
      bslib::nav_panel(
        title = "Birds", 
        
        mod_map_ui("map_birds", choices = element_choices(ELEMENT_NAMES$bird))
        
      ), 
      
      bslib::nav_panel(
        title = "Trees", 
        
        mod_map_ui("map_trees", choices = element_choices(c(ELEMENT_NAMES$tree, "biomass")))
        
      ), 
      
      bslib::nav_panel(
        title = "Fire", 
        
        mod_map_ui("map_fire", choices = element_choices("burn"), label = "Map:")
        
      ), 
      
      # "Side-by-Side" Pages ----
      # Cumulative Burn is left out on purpose: a side-by-side of it is not a
      # meaningful comparison.
      bslib::nav_menu(
        title = "Side-by-Side", 
        
        bslib::nav_panel(
          title = "Birds", 
          mod_sidebyside_ui("sidebyside_birds", choices = element_choices(ELEMENT_NAMES$bird))
        ),
        
        bslib::nav_panel(
          title = "Trees", 
          mod_sidebyside_ui("sidebyside_trees", choices = element_choices(c(ELEMENT_NAMES$tree, "biomass")))
        )
        
      ), 
      
      # "Regions" Page ----
      bslib::nav_panel(
        title = "Regions", 
        
        mod_regions_ui("regions_ui_1")
        
      ), 

      # "Methods" Page ----
      bslib::nav_panel(
        title = "Methods", 
        
        mod_methods_ui("methods_ui_1")
        
      ), 
      
      # "Download" Page ----
      bslib::nav_panel(
        title = "Download", 
        
        mod_download_ui("download_ui_1")
        
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


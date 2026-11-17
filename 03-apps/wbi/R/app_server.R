#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic

  message("INFO This is ", get_golem_config("golem_name"),
    " v", get_golem_config("golem_version"),
    " running in ", 
    if (get_golem_config("app_prod")) "production" else "development",
    " mode")
  message("INFO App base URL set to ", get_golem_config("app_baseurl"))

  
  mod_map_server("map_birds")
  mod_map_server("map_trees")
  mod_map_server("map_fire")
  
  mod_sidebyside_server("sidebyside_birds", choices = element_choices(ELEMENT_NAMES$bird))
  mod_sidebyside_server("sidebyside_trees", choices = element_choices(c(ELEMENT_NAMES$tree, "biomass")))
  
  mod_regions_server("regions_ui_1")
  
  mod_methods_server("methods_ui_1")
  
  mod_download_server("download_ui_1")
  
}

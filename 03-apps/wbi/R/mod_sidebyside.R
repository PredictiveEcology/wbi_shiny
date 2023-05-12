#' sidebyside UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_sidebyside_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    div(
      class = "outer",
      
      leaflet::leafletOutput(
        outputId = ns("map_2x"), 
        width = "100%", 
        height = "100%"
      ), 
      
      absolutePanel(
        id = "controls_2x", 
        class = "panel panel-default", 
        fixed = TRUE,
        draggable = TRUE, 
        top = 80, 
        left = "auto", 
        right = 20, 
        bottom = "auto",
        width = 330, 
        height = "auto", 
        
        build_accordion(
          id = "map_2x",
          header = "You are now viewing:",
          content = shiny::tags$ul(
            
            # Region ("Full Extent" as default)
            # Element Type (same default as "Map" page)
            # Element (same as "Map" page)
            # Radio Button - "Compare by Scenario" / "Compare by Time Period"
            # DropDown: Left-hand side map selection
            # DropDown: Right-hand side map selection
            
            shiny::tags$li(
              shiny::span(
                "Region: ",
                shiny::textOutput(
                  outputId = ns("region_text_2x"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            ),
            
            shiny::tags$li(
              shiny::span(
                "Species Group: ", 
                shiny::textOutput(
                  outputId = ns("species_group_text_2x"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            ),
            
            shiny::tags$li(
              shiny::span(
                "Species Name: ", 
                shiny::textOutput(
                  outputId = ns("species_name_text_2x"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            ),
            
            shiny::tags$li(
              shiny::span(
                "Comparing by: ", 
                shiny::textOutput(
                  outputId = ns("comparison_text_2x"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            ),
            
            shiny::tags$li(
              shiny::span(
                "Left Map: ", 
                shiny::textOutput(
                  outputId = ns("left_map_text_2x"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            ),
            
            shiny::tags$li(
              shiny::span(
                "Right Map: ", 
                shiny::textOutput(
                  outputId = ns("right_map_text_2x"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            )
            
          )
        ),
        
        shiny::actionButton(
          inputId = ns("edit_map_settings_2x"),
          label = "Change Preferences",
          icon = shiny::icon("gear")
        )
        
      )
      
    )
    
  )
}

#' sidebyside Server Functions
#'
#' @noRd 
mod_sidebyside_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    ## Set Initial Filter Selections ----
    # Create a `reactiveValues` list to hold current selections for each filter;
    # This will help make user choices redundant when re-launching the modal;
    # Start by setting some defaults that will appear the first time the modal
    # is launched
    current_selections_2x <- shiny::reactiveValues(
      region = "Full Extent",
      element_type = "bird",
      element_choices = ELEMENT_NAMES$bird,
      element = ELEMENT_NAMES$bird[[1]],
      comparison_type = "scenario",
      map_left_choices = SCENARIOS,
      map_left = SCENARIOS[[1]],
      map_right_choices = SCENARIOS,
      map_right = SCENARIOS[[2]],
      opacity = 0.8,
      element_type_display = "bird",
      element_display = ELEMENT_NAMES$bird[[1]]
    )
    
    ## Modal ----
    # Create modal to hold all input widgets / filters
    shiny::observeEvent(input$edit_map_settings_2x, {
      
      modal <- shiny::modalDialog(
        
        title = "Set Map Preferences",
        
        shiny::selectInput(
          inputId = ns("map_region_2x"),
          label = "Region",
          choices = c("Full Extent"),   # TODO //
          selected = current_selections_2x$region
        ),
        
        radioButtons(
          inputId = ns("map_element_type_2x"), 
          label = "Species Group:", 
          choices = list("Birds" = "bird", "Trees" = "tree"), 
          selected = current_selections_2x$element_type
        ), 
        
        selectInput(
          inputId = ns("map_element_2x"),
          label = "Species Name:", 
          choices = current_selections_2x$element_choices,
          selected = current_selections_2x$element
        ),
        
        radioButtons(
          inputId = ns("map_comparison_type_2x"), 
          label = "Comparison Type:", 
          choices = list("Period" = "period", "Scenario" = "scenario"), 
          selected = current_selections_2x$comparison_type
        ), 
        
        selectInput(
          inputId = ns("map_left_2x"),
          label = "Left Map:",
          choices = current_selections_2x$map_left_choices,
          selected = current_selections_2x$map_left
        ),
        
        selectInput(
          inputId = ns("map_right_2x"),
          label = "Right Map:",
          choices = current_selections_2x$map_right_choices,
          selected = current_selections_2x$map_right
        ),
        
        sliderInput(
          inputId = ns("map_opacity_2x"), 
          label = "Opacity:", 
          min = 0, 
          max = 1, 
          value = current_selections_2x$opacity
        ), 
        
        footer = shiny::actionButton(
          inputId = ns("close_modal_2x"), 
          label = "Apply"
        ),
        
        size = "s"
        
      )
      
      shiny::showModal(modal)
      
    })   # run once on load
    
    ## Filter Updates ----
    
    # Update the choices in the "Species Name" dropdown filter based upon the 
    # selected "Species Group" radio button
    shiny::observeEvent(input$map_element_type_2x, {
      
      shiny::req(
        current_selections_2x$element_type,
        input$map_element_type_2x
      )
      
      # If there is a change in the "Species Group" radio button...
      if (current_selections_2x$element_type != input$map_element_type_2x) {
        
        # ... update the choices in the "Species Name" dropdown filter list
        updateSelectInput(
          session = session, 
          inputId = "map_element_2x", 
          choices = ELEMENT_NAMES[[input$map_element_type_2x]]
        )
        
      }
      
      # Overwrite the `element_type` reactiveValue to the currently-selected 
      # "Species Group" radio button value
      current_selections_2x$element_type <- input$map_element_type_2x
      
    })
    
    # Update the choices in the "Left Map" and "Right Map" dropdown filters 
    # based upon the selected "Compare By" radio button
    shiny::observeEvent(input$map_comparison_type_2x, {
      
      shiny::req(
        current_selections_2x$comparison_type,
        input$map_comparison_type_2x
      )
      
      # If there is a change in the "Compare By" radio button...
      if (current_selections_2x$comparison_type != input$map_comparison_type_2x) {
        
        if (input$map_comparison_type_2x == "scenario") {
          
          choices <- SCENARIOS
          
        } else {
          
          choices <- ELEMENTS[ELEMENTS$species_code == input$map_element_2x, ] |> 
            get_period_choices()
          
        }
        
        # ... update the choices in the "Left Map" dropdown filter list
        updateSelectInput(
          session = session, 
          inputId = "map_left_2x", 
          choices = choices
        )
        
        # ... update the choices in the "Right Map" dropdown filter list
        updateSelectInput(
          session = session, 
          inputId = "map_right_2x", 
          choices = choices
        )
        
      }
      
      # Overwrite the `comparison_type` reactiveValue to the currently-selected 
      # "Compare By" radio button value
      current_selections_2x$comparison_type <- input$map_comparison_type_2x
      
    })
    
    # # Update the options under "Element Name" based upon the selection in the 
    # # "Element Type" radio button
    # observe({
    #   
    #   element_type <- tolower(input$map2x_element_type)
    #   
    #   updateSelectInput(
    #     session = session, 
    #     inputId = "map2x_element", 
    #     choices = ELEMENT_NAMES[[element_type]]
    #   )
    #   
    # })
    
    # When the "Apply" button is clicked in the modal, capture the inputs to
    # apply when the modal is re-launched
    shiny::observeEvent(input$close_modal_2x, {
      
      if (input$map_comparison_type_2x == "scenario") {
        
        choices <- SCENARIOS
        
      } else {
        
        choices <- ELEMENTS[ELEMENTS$species_code == input$map_element_2x, ] |> 
          get_period_choices()
        
      }
      
      current_selections_2x$region <- input$map_region_2x
      current_selections_2x$element_type <- input$map_element_type_2x
      current_selections_2x$element_choices <- ELEMENT_NAMES[[input$map_element_type_2x]]
      current_selections_2x$element <- input$map_element_2x
      current_selections_2x$comparison_type <- input$map_comparison_type_2x
      current_selections_2x$map_left_choices <- choices
      current_selections_2x$map_left <- input$map_left_2x
      current_selections_2x$map_right_choices <- choices
      current_selections_2x$map_right <- input$map_right_2x
      current_selections_2x$opacity <- input$map_opacity_2x
      
      current_selections_2x$element_type_display <- current_selections_2x$element_type
      current_selections_2x$element_display <- current_selections_2x$element
      
      shiny::removeModal(session = session)
      
    })
    
    # Render the map
    output$map_2x <- leaflet::renderLeaflet({
      
      if (current_selections_2x$comparison_type == "scenario") {
        
        MS1 <- MAPSTATS[
          MAPSTATS$element_name == current_selections_2x$element & 
            MAPSTATS$scenario == current_selections_2x$map_left & 
            MAPSTATS$year == "2100",  # TODO // change this to user-specified
        ]
        
        MS2 <- MAPSTATS[
          MAPSTATS$element_name == current_selections_2x$element & 
            MAPSTATS$scenario == current_selections_2x$map_right & 
            MAPSTATS$year == "2100",  # TODO // change this to user-specified
        ]
        
      } else {
        
        MS1 <- MAPSTATS[
          MAPSTATS$element_name == current_selections_2x$element & 
            MAPSTATS$scenario == "landrcs-fs-v6a" &   # TODO // change this to user-specified
            MAPSTATS$year == current_selections_2x$map_left,
        ]
        
        MS2 <- MAPSTATS[
          MAPSTATS$element_name == current_selections_2x$element & 
            MAPSTATS$scenario == "landrcs-fs-v6a" &   # TODO // change this to user-specified
            MAPSTATS$year == current_selections_2x$map_right,
        ]
        
      }
      
      base_map2x() |> 
        add_element2x(
          element = current_selections_2x$element, 
          by = current_selections_2x$comparison_type,
          opacity = current_selections_2x$opacity,
          max1 = MS1$max,
          max2 = MS2$max,
          pal_max1 = MS1$pal_max,
          pal_max2 = MS2$pal_max
        ) |> 
        leaflet::addMeasure(
          position = "topleft"
        ) |>
        htmlwidgets::onRender("
          function(el, x) {
            this.on('baselayerchange', function(e) {
              e.layer.bringToBack();
            })
          }
        ")
    })
    
  })
}

## To be copied in the UI
# mod_sidebyside_ui("sidebyside_ui_1")

## To be copied in the server
# mod_sidebyside_server("sidebyside_ui_1")

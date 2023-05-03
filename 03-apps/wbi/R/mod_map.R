#' map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_map_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    div(
      class = "outer", 
      
      # Map ----
      leaflet::leafletOutput(
        outputId = ns("map"), 
        width = "100%", 
        height = "100%"
      ), 
      
      # Panel ----
      absolutePanel(
        id = "controls", 
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
          id = "map",
          header = "You are now viewing:",
          content = shiny::tags$ul(
            
            # shiny::tags$li(
            #   shiny::span(
            #     "Region: ", 
            #     shiny::textOutput(
            #       outputId = "region_text", 
            #       inline = TRUE
            #     ) |> shiny::tags$em()
            #   )
            # ),
            
            shiny::tags$li(
              shiny::span(
                "Species Group: ", 
                shiny::textOutput(
                  outputId = ns("species_group_text"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            ),
            
            shiny::tags$li(
              shiny::span(
                "Species Name: ", 
                shiny::textOutput(
                  outputId = ns("species_name_text"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            ),
            
            shiny::tags$li(
              shiny::span(
                "Scenario: ", 
                shiny::textOutput(
                  outputId = ns("scenario_text"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            ),
            
            shiny::tags$li(
              shiny::span(
                "Time Period: ", 
                shiny::textOutput(
                  outputId = ns("period_text"),
                  inline = TRUE
                ) |> shiny::tags$em()
              )
            )
            
          )
        ),
        
        shiny::actionButton(
          inputId = ns("edit_map_settings"),
          label = "Change Preferences",
          icon = shiny::icon("gear")
        )
        
      )
    )
    
  )
}

#' map Server Functions
#'
#' @noRd 
mod_map_server <- function(id, elements){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    # Create a `reactiveValues` list to hold current selections for each filter;
    # This will help make user choices redundant when re-launching the modal;
    # Start by setting some defaults that will appear the first time the modal
    # is launched
    current_selections <- shiny::reactiveValues()
    current_selections$element_type <- "bird"
    #   element_type = list("Birds" = "bird"),
    #   element_choices = ELEMENT_NAMES$bird,
    #   element = ELEMENT_NAMES$bird[1],
    #   scenario = SCENARIOS[1],
    #   period = 2011,
    #   opacity = 0.8
    # )
    
    ## Modal ----
    modal <- shiny::modalDialog(
      
      title = "Set Map Preferences",
      
      radioButtons(
        inputId = ns("map_element_type"), 
        label = "Species Group:", 
        choices = list("Birds" = "bird", "Trees" = "tree"), 
        selected = "bird"
      ), 
      
      selectInput(
        inputId = ns("map_element"),
        label = "Species Name:", 
        choices = ELEMENT_NAMES$bird
      ),
      
      selectInput(
        inputId = ns("map_scenario"),
        label = "Scenario:",
        choices = SCENARIOS
      ),
      
      selectInput(
        inputId = ns("map_period"), 
        label = "Time Period:", 
        choices = c(2011, 2100)
      ), 
      
      sliderInput(
        inputId = ns("map_opacity"), 
        label = "Opacity:", 
        min = 0, 
        max = 1, 
        value = 0.8
      ), 
      
      footer = shiny::actionButton(
        inputId = ns("close_modal"), 
        label = "Apply"
      ),
      size = "s"
      
    )
    
    # Show the modal on launch (once)
    shiny::showModal(modal)
    
    # Filter Updates ----
    # Update the choices in the "Species Name" dropdown filter based upon the 
    # selected "Species Group" radio button
    shiny::observe({
      
      shiny::req(
        current_selections$element_type,
        input$map_element_type
      )
        
      if (current_selections$element_type != input$map_element_type) {
        
        updateSelectInput(
          session = session, 
          inputId = "map_element", 
          choices = ELEMENT_NAMES[[input$map_element_type]]
        )
        
        current_selections$element_type <- input$map_element_type
        
      }
      
    })
    
    # When the "Apply" button is clicked in the modal, capture the inputs to
    # apply when the modal is re-launched
    shiny::observeEvent(input$close_modal, {
      
      current_selections$element_type <- input$map_element_type
      current_selections$element_choices <- ELEMENT_NAMES[[input$map_element_type]]
      current_selections$element <- input$map_element
      current_selections$scenario <- input$map_scenario
      current_selections$period <- input$map_period
      current_selections$opacity <- input$map_opacity
      
      shiny::removeModal(session = session)
      
    })
    
    # Re-launch the modal when the "Change Preferences" button is clicked
    shiny::observeEvent(input$edit_map_settings, {
      
      shiny::showModal(modal)
      
      shiny::updateRadioButtons(
        session = session,
        inputId = "map_element_type",
        selected = current_selections$element_type
      )
      
      shiny::updateSelectInput(
        session = session,
        inputId = "map_element",
        choices = current_selections$element_choices,
        selected = current_selections$element
      )
      
      shiny::updateSelectInput(
        session = session,
        inputId = "map_scenario",
        selected = current_selections$scenario
      )
      
      shiny::updateSelectInput(
        session = session,
        inputId = "map_period",
        selected = current_selections$period
      )
      
      shiny::updateSliderInput(
        session = session,
        inputId = "map_opacity",
        value = current_selections$opacity
      )
      
    })
    
    # Filter Updates ----
    # Update the options under "Element Name" based upon the selection in the 
    # "Element Type" radio button
    # shiny::observeEvent(input$map_element_type, {
    #   
    #   if (input$map_element_type != current_selections$element_type) {
    #     
    #     updateSelectInput(
    #       session = session, 
    #       inputId = "map_element", 
    #       choices = ELEMENT_NAMES[[input$map_element_type]], 
    #       selected = ELEMENT_NAMES[[input$map_element_type]][1]
    #     )
    #     
    #   }
    #   
    # })
    
    # Map ----
    output$map <- leaflet::renderLeaflet({
      
      shiny::req(
        input$map_element,
        input$map_scenario,
        input$map_period,
        input$map_opacity
      )
      
      MS <- MAPSTATS[
        MAPSTATS$element_name == input$map_element & 
          MAPSTATS$scenario == input$map_scenario & 
          MAPSTATS$year == input$map_period,
      ]
      base_map() |> 
        add_element(
          element = input$map_element, 
          scenario = input$map_scenario, 
          period = input$map_period,
          opacity = input$map_opacity,
          max = MS$max, 
          pal_max = MS$pal_max
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
    
    # Summary Text ----
    
    # Render "Species Group" selection text
    output$species_group_text <- shiny::renderText(
      
      ifelse(input$map_element_type == "bird", "Birds", "Trees")
      
    )
    
    # Render "Species Name" selection text
    output$species_name_text <- shiny::renderText({
      
      shiny::req(
        input$map_element_type,
        input$map_element
      )
      
      lookup_element_name_by_value(
        list = ELEMENT_NAMES,
        type = input$map_element_type,
        value = input$map_element
      )
      
    })
    
    # Render "Scenario" selection text
    output$scenario_text <- shiny::renderText(
      
      names(
        SCENARIOS[SCENARIOS == input$map_scenario]
      )
      
    )
    
    # Render "Period" selection text
    output$period_text <- shiny::renderText(input$map_period)
    
  })
}

## To be copied in the UI
# mod_map_ui("map_ui_1")

## To be copied in the server
# mod_map_server("map_ui_1")

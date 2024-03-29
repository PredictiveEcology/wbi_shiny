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
      
      # Map ----
      leaflet::leafletOutput(
        outputId = ns("map_2x"), 
        width = "100%", 
        height = "100%"
      ), 
      
      # Panel ----
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
        
        shiny::br(),
        
        ## Species drop-down filter ----
        shinyWidgets::pickerInput(
          inputId = ns("map_element_2x"),
          label = "Species Name:", 
          choices = ELEMENT_NAMES, 
          selected = ELEMENT_NAMES$bird[[1]], 
          options = list(
            `live-search` = TRUE
            # style = "border-color: #999999;"
            # style = paste0(
            #   "background-color: white; ",
            #   "border-color: #999999; ",
            #   "font-family: 'Helvetica Neue' Helvetica; ",
            #   "font-weight: 200;"
            # )
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
    
    PERIODS_init <- get_period_choices(
      ELEMENTS[ELEMENTS$species_code == ELEMENT_NAMES$bird[[1]], ]
    )
    
    ## Set Initial Filter Selections ----
    # Create a `reactiveValues` list to hold current selections for each filter
    # in the modal; this will help make user choices redundant when re-launching
    # the modal.
    # Start by setting some defaults that will appear the first time the modal
    # is launched
    current_selections_2x <- shiny::reactiveValues(
      region = "full-extent",
      element_type = "bird",
      comparison_type = "period",
      map_left_choices = PERIODS_init,
      map_left = PERIODS_init[1],
      map_right_choices = PERIODS_init,
      map_right = max(PERIODS_init),
      constant_choices = SCENARIOS,
      constant = SCENARIOS[[1]],
      opacity = 0.8
    )
    
    ## Modal ----
    # Create modal to hold all input widgets / filters
    shiny::observeEvent(input$edit_map_settings_2x, {
      
      modal <- shiny::modalDialog(
        
        title = "Set Map Preferences",
        
        shiny::fluidRow(
          
          shiny::column(
            width = 6, 
            
            shiny::selectInput(
              inputId = ns("map_region_2x"),
              label = "Region",
              choices = REGIONS,
              selected = current_selections_2x$region
            )
            
          ),
          
          shiny::column(
            width = 6,
            
            radioButtons(
              inputId = ns("map_comparison_type_2x"), 
              label = "Comparison Type:", 
              choices = list("Period" = "period", "Scenario" = "scenario"), 
              selected = current_selections_2x$comparison_type,
              inline = TRUE
            )
            
          )
          
        ), 
        
        shiny::fluidRow(
          
          shiny::column(
            width = 6,
            
            sliderInput(
              inputId = ns("map_opacity_2x"), 
              label = "Opacity:", 
              min = 0, 
              max = 1, 
              value = current_selections_2x$opacity
            )
            
          ),
          
          shiny::column(
            width = 6,
            
            selectInput(
              inputId = ns("map_constant_2x"),
              label = "Scenario:",
              choices = current_selections_2x$constant_choices,
              selected = current_selections_2x$constant
            )
            
          )
          
        ),
        
        shiny::fluidRow(
          
          shiny::column(
            width = 6,
            
            selectInput(
              inputId = ns("map_left_2x"),
              label = "Left Map:",
              choices = current_selections_2x$map_left_choices,
              selected = current_selections_2x$map_left
            )
            
          ),
          
          shiny::column(
            width = 6,
            
            selectInput(
              inputId = ns("map_right_2x"),
              label = "Right Map:",
              choices = current_selections_2x$map_right_choices,
              selected = current_selections_2x$map_right
            )
            
          )
          
          
        ),
        
        footer = shiny::actionButton(
          inputId = ns("close_modal_2x"), 
          label = "Apply"
        ),
        
        size = "l",
        easyClose = TRUE
        
      )
      
      shiny::showModal(modal)
      
    })
    
    ## Filter Updates ----
    
    # Update the choices in the "Left Map" and "Right Map" drop-down filters 
    # based upon the selected "Compare By" radio button
    shiny::observeEvent(input$map_comparison_type_2x, {
      
      shiny::req(input$map_element_2x)
      
      if (input$map_comparison_type_2x == "scenario") {
        
        map_choices <- SCENARIOS
        constant_label <- "Period:"
        constant_choices <- ELEMENTS[ELEMENTS$species_code == input$map_element_2x, ] |> 
          get_period_choices()
        
      } else {
        
        map_choices <- ELEMENTS[ELEMENTS$species_code == input$map_element_2x, ] |> 
          get_period_choices()
        constant_label <- "Scenario:"
        constant_choices <- SCENARIOS
        
      }
      
      # ... update the choices in the "Left Map" dropdown filter list
      updateSelectInput(
        session = session, 
        inputId = "map_left_2x", 
        choices = map_choices,
        selected = map_choices[[1]]
      )
      
      # ... update the choices in the "Right Map" dropdown filter list
      updateSelectInput(
        session = session, 
        inputId = "map_right_2x", 
        choices = map_choices,
        selected = map_choices[[length(map_choices)]]
      )
      
      # ... update the choices in the "Constant" dropdown filter list
      updateSelectInput(
        session = session,
        label = constant_label,
        inputId = "map_constant_2x", 
        choices = constant_choices
      )
      
    })
    
    # When the "Apply" button is clicked in the modal, capture the inputs to
    # apply when the modal is re-launched
    shiny::observeEvent(input$close_modal_2x, {
      
      if (input$map_comparison_type_2x == "scenario") {
        
        map_choices <- SCENARIOS
        constant_choices <- ELEMENTS[ELEMENTS$species_code == input$map_element_2x, ] |> 
          get_period_choices()
        
      } else {
        
        map_choices <- ELEMENTS[ELEMENTS$species_code == input$map_element_2x, ] |> 
          get_period_choices()
        constant_choices <- SCENARIOS
        
      }
      
      current_selections_2x$region <- input$map_region_2x
      current_selections_2x$comparison_type <- input$map_comparison_type_2x
      current_selections_2x$map_left_choices <- map_choices
      current_selections_2x$map_left <- input$map_left_2x
      current_selections_2x$map_right_choices <- map_choices
      current_selections_2x$map_right <- input$map_right_2x
      current_selections_2x$constant_choices <- constant_choices
      current_selections_2x$constant <- input$map_constant_2x
      
      current_selections_2x$opacity <- input$map_opacity_2x
      
      shiny::removeModal(session = session)
      
    })
    
    # Map ----
    # Render the map
    output$map_2x <- leaflet::renderLeaflet({
      
      if (current_selections_2x$comparison_type == "scenario") {
        
        MS1 <- MAPSTATS[
          MAPSTATS$region == current_selections_2x$region & 
            MAPSTATS$element == input$map_element_2x & 
            MAPSTATS$scenario == current_selections_2x$map_left & 
            MAPSTATS$period == current_selections_2x$constant,
        ]
        
        MS2 <- MAPSTATS[
          MAPSTATS$region == current_selections_2x$region & 
            MAPSTATS$element == input$map_element_2x & 
            MAPSTATS$scenario == current_selections_2x$map_right & 
            MAPSTATS$period == current_selections_2x$constant,  
        ]
        
      } else {
        
        MS1 <- MAPSTATS[
          MAPSTATS$region == current_selections_2x$region & 
            MAPSTATS$element == input$map_element_2x & 
            MAPSTATS$period == current_selections_2x$map_left & 
            MAPSTATS$scenario == current_selections_2x$constant,
        ]
        
        MS2 <- MAPSTATS[
          MAPSTATS$region == current_selections_2x$region & 
            MAPSTATS$element == input$map_element_2x & 
            MAPSTATS$period == current_selections_2x$map_right & 
            MAPSTATS$scenario == current_selections_2x$constant,  
        ]
        
      }
      
      # Scale the color palette from zero (if `app_usemin = FALSE`) or from the
      # min value in the data
      if (get_golem_config("app_usemin")) {
        
        legend_start <- min(c(MS1$min, MS2$min))
        
        
      } else {
        
        legend_start <- 0
        
      }
      
      # Equalize the color palettes across both left and right maps (to align 
      # legend gradients)
      pal_max1 <- scales::rescale(
        MS1$max,
        to = c(1, 100),
        from = c(legend_start, max(c(MS1$max, MS2$max)))
      ) |> 
        floor()
      
      pal_max2 <- scales::rescale(
        MS2$max,
        to = c(1, 100),
        from = c(legend_start, max(c(MS1$max, MS2$max)))
      ) |> 
        floor()
      
      # Render the side-by-side map
      base_map2x() |> 
        add_element2x(
          region = current_selections_2x$region,
          element = input$map_element_2x, 
          compare_by = current_selections_2x$comparison_type,
          left_map = current_selections_2x$map_left,
          right_map = current_selections_2x$map_right,
          constant = current_selections_2x$constant,
          opacity = current_selections_2x$opacity,
          min1 = ifelse(get_golem_config("app_usemin"), MS1$min, 0),
          min2 = ifelse(get_golem_config("app_usemin"), MS2$min, 0),
          max1 = MS1$max,
          max2 = MS2$max,
          pal_max1 = pal_max1,
          pal_max2 = pal_max2
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

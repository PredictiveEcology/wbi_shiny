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
        
        build_accordion(
          id = "map_2x",
          header = "You are now viewing:",
          content = shiny::tags$ul(
            
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
            ),
            
            shiny::tags$li(
              shiny::span(
                shiny::textOutput(
                  outputId = ns("constant_title_text_2x"),
                  inline = TRUE
                ),
                # ": ",
                shiny::textOutput(
                  outputId = ns("constant_text_2x"),
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
      region = "full-extent",
      element_type = "bird",
      element = ELEMENT_NAMES$bird[[1]],
      comparison_type = "scenario",
      map_left_choices = SCENARIOS,
      map_left = SCENARIOS[[1]],
      map_right_choices = SCENARIOS,
      map_right = SCENARIOS[[2]],
      constant_choices = get_period_choices(
        ELEMENTS[ELEMENTS$species_code == ELEMENT_NAMES$bird[[1]], ]
      ),
      constant = get_period_choices(
        ELEMENTS[ELEMENTS$species_code == ELEMENT_NAMES$bird[[1]], ]
      )[1],
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
            ),
            
            shinyWidgets::pickerInput(
              inputId = ns("map_element_2x"),
              label = "Species Name:", 
              choices = ELEMENT_NAMES, 
              selected = current_selections_2x$element, 
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
            
            radioButtons(
              inputId = ns("map_comparison_type_2x"), 
              label = "Comparison Type:", 
              choices = list("Period" = "period", "Scenario" = "scenario"), 
              selected = current_selections_2x$comparison_type,
              inline = TRUE
            ), 
            
            selectInput(
              inputId = ns("map_constant_2x"),
              label = "Period:",
              choices = current_selections_2x$constant_choices,
              selected = current_selections_2x$constant
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
            )
            
          )
          
        ),
        
        footer = shiny::actionButton(
          inputId = ns("close_modal_2x"), 
          label = "Apply"
        ),
        
        size = "l"
        
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
        selected = map_choices[[2]]
      )
      
      # ... update the choices in the "Right Map" dropdown filter list
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
      current_selections_2x$element <- input$map_element_2x
      current_selections_2x$comparison_type <- input$map_comparison_type_2x
      current_selections_2x$map_left_choices <- map_choices
      current_selections_2x$map_left <- input$map_left_2x
      current_selections_2x$map_right_choices <- map_choices
      current_selections_2x$map_right <- input$map_right_2x
      current_selections_2x$constant_choices <- constant_choices
      current_selections_2x$constant <- input$map_constant_2x
      
      current_selections_2x$opacity <- input$map_opacity_2x
      
      current_selections_2x$element_type <- lookup_element_type_by_value(
        x = ELEMENT_NAMES, 
        value = input$map_element_2x
      )
      
      # current_selections_2x$element_type_display <- current_selections_2x$element_type
      # current_selections_2x$element_display <- current_selections_2x$element
      
      shiny::removeModal(session = session)
      
    })
    
    # Map ----
    # Render the map
    output$map_2x <- leaflet::renderLeaflet({
      
      if (current_selections_2x$comparison_type == "scenario") {
        
        MS1 <- MAPSTATS[
          MAPSTATS$region == current_selections_2x$region & 
            MAPSTATS$element == current_selections_2x$element & 
            MAPSTATS$scenario == current_selections_2x$map_left & 
            MAPSTATS$period == current_selections_2x$constant,
        ]
        
        MS2 <- MAPSTATS[
          MAPSTATS$region == current_selections_2x$region & 
            MAPSTATS$element == current_selections_2x$element & 
            MAPSTATS$scenario == current_selections_2x$map_right & 
            MAPSTATS$period == current_selections_2x$constant,  
        ]
        
      } else {
        
        MS1 <- MAPSTATS[
          MAPSTATS$region == current_selections_2x$region & 
            MAPSTATS$element == current_selections_2x$element & 
            MAPSTATS$period == current_selections_2x$map_left & 
            MAPSTATS$scenario == current_selections_2x$constant,
        ]
        
        MS2 <- MAPSTATS[
          MAPSTATS$region == current_selections_2x$region & 
            MAPSTATS$element == current_selections_2x$element & 
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
          element = current_selections_2x$element, 
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
    
    # Summary Text ----
    
    # Render "Region" selection text
    output$region_text_2x <- shiny::renderText(
      
      lookup_element_name_by_value(
        x = REGIONS,
        value = current_selections_2x$region
      )
      
    )
    
    # Render "Species Group" selection text
    output$species_group_text_2x <- shiny::renderText(
      
      current_selections_2x$element_type |> 
        tools::toTitleCase()
      
    )
    
    # Render "Species Name" selection text
    output$species_name_text_2x <- shiny::renderText({
      
      shiny::req(current_selections_2x$element_type)
      
      lookup_element_name_by_value(
        x = ELEMENT_NAMES[[current_selections_2x$element_type]],
        value = current_selections_2x$element
      )
      
    })
    
    # Render "Comparing By" selection text
    output$comparison_text_2x <- shiny::renderText(
      
      current_selections_2x$comparison_type |> 
        tools::toTitleCase()
      
    )
    
    # Render "Left Map" selection text
    output$left_map_text_2x <- shiny::renderText({
      
      if (current_selections_2x$comparison_type == "scenario") {
        lookup_element_name_by_value(
          x = SCENARIOS, 
          value = current_selections_2x$map_left
        )
      } else {
        current_selections_2x$map_left
      }
      
    })
    
    # Render "Right Map" selection text
    output$right_map_text_2x <- shiny::renderText({
      
      if (current_selections_2x$comparison_type == "scenario") {
        lookup_element_name_by_value(
          x = SCENARIOS, 
          value = current_selections_2x$map_right
        )
      } else {
        current_selections_2x$map_right
      }
      
    })
    
    # Render "Constant" title text
    output$constant_title_text_2x <- shiny::renderText({
      
      if (current_selections_2x$comparison_type == "scenario") {
        "Period:"
      } else {
        "Scenario:"
      }
      
    })
    
    # Render "Constant" selection text
    output$constant_text_2x <- shiny::renderText(current_selections_2x$constant)
    
  })
}

## To be copied in the UI
# mod_sidebyside_ui("sidebyside_ui_1")

## To be copied in the server
# mod_sidebyside_server("sidebyside_ui_1")

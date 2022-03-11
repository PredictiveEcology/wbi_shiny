ui <- fluidPage(
    tags$head(includeCSS("styles.css")),
    tags$head(includeScript("clipboard.min.js")),
    #theme = shinytheme("united"),
    navbarPage("WBI",
        tabPanel("Map",
            div(class="outer",
                leafletOutput("map", width="100%", height="100%"),
                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                    draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                    width = 330, height = "auto",
                    
                    selectInput("map_element", "Element name:", ELEMENT_NAMES),
                    selectInput("map_scenario", "Scenario:", SCENARIOS),
                    selectInput("map_period", "Time periods:", c(2011, 2100)),
                    sliderInput("map_opacity", label = "Opacity:", 
                        min = 0, value = 0.8, max = 1)
                )
            )
        ),
        tabPanel("Side by side",
            div(class="outer",
                leafletOutput("map2x", width="100%", height="100%"),
                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                    draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                    width = 330, height = "auto",
                    
                    selectInput("map2x_element", "Element name:", ELEMENT_NAMES),
                    radioButtons("map2x_by", label = "Compare by:",
                        choices = c("Scenario"="scenario", "Period"="period")),
                    sliderInput("map2x_opacity", label = "Opacity:", 
                        min = 0, value = 0.8, max = 1)
                )
            )
        ),
        tabPanel("Regions",
            titlePanel("Regional summaries"),
            p("TBD")
        ),
        tabPanel("Assets",
            titlePanel("Find links to results"),
            reactableOutput("assets_tab")
        )
    )
)

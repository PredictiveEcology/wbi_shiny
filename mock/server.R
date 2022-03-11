server <- function(input, output) {
    output$map <- renderLeaflet({
        base_map()
    })
    observeEvent(input$map_element, {
        leafletProxy("map") %>%
        clearControls() %>%
        add_element(input$map_element, 
            input$map_scenario, 
            input$map_period,
            input$map_opacity)
    })
    observeEvent(input$map_scenario, {
        leafletProxy("map") %>%
        clearControls() %>%
        add_element(input$map_element, 
            input$map_scenario, 
            input$map_period,
            input$map_opacity)
    })
    observeEvent(input$map_period, {
        leafletProxy("map") %>%
        clearControls() %>%
        add_element(input$map_element, 
            input$map_scenario, 
            input$map_period,
            input$map_opacity)
    })
    observeEvent(input$map_opacity, {
        leafletProxy("map") %>%
        clearControls() %>%
        add_element(input$map_element, 
            input$map_scenario, 
            input$map_period,
            input$map_opacity)
    })
    output$map2x <- renderLeaflet({
        base_map2x() %>%
        add_element2x(input$map2x_element, 
            input$map2x_by,
            input$map2x_opacity)

    })
    output$assets_tab <- renderReactable({
        assets_table(x)
    })
}

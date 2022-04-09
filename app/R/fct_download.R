


#' Build the Interactive "Download" Table
#'
#' @param data A data frame containing the data to be displayed in the table
#'
#' @return An interactive *{reactable}* data table
#'
#' @noRd
#' 
#' @examples 
#' download_table(MAIN)
download_table <- function(data) {
  
  reactable::reactable(
    data,
    rownames = FALSE,
    filterable = TRUE,
    highlight = TRUE,
    showPageSizeOptions = TRUE,
    columns = list(
      group = reactable::colDef(show = FALSE),
      species_code = reactable::colDef(show = FALSE),
      common_name = reactable::colDef(name = "Common Name"),
      scientific_name = reactable::colDef(name = "Scientific Name"),
      scenario = reactable::colDef(name = "Scenario"),
      period = reactable::colDef(name = "Time Period"),
      resolution = reactable::colDef(name = "Resolution"),
      path = reactable::colDef(
        name = "Link", 
        align = "left", 
        sortable = FALSE, 
        filterable = FALSE, 
        html = TRUE, cell = function(value, index) {
          sprintf('<a href="%s" target="_blank">%s</a>',
                  paste0(get_golem_config("app_baseurl"),#"https://wbi-nwt.analythium.app/",
                         LINKS$path[index]),
                  "Link")
        })
    ),
    theme = reactable::reactableTheme(
      borderColor = "#dfe2e5",
      stripedColor = "#f6f8fa",
      highlightColor = "#f0f5f9",
      cellPadding = "8px 12px",
      searchInputStyle = list(width = "100%"),
      rowSelectedStyle = list(
        backgroundColor = "#eee",
        boxShadow = "inset 2px 0 0 0 #69B34C"
      )
    )
  )
  
}

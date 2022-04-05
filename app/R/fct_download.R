


#' Build the Interactive "Download" Table
#'
#' @param x A data frame containing the data to be displayed in the table
#'
#' @return An interactive *{reactable}* data table
#'
#' @noRd
#' 
download_table <- function(x) {
  
  reactable::reactable(
    x,
    rownames = FALSE,
    filterable = TRUE,
    highlight = TRUE,
    showPageSizeOptions = TRUE,
    columns = list(
      group = reactable::colDef(name = "Group"),
      species_code = reactable::colDef(name = "Species Code"),
      common_name = reactable::colDef(name = "Common Name"),
      scientific_name = reactable::colDef(name = "Scientific Name"),
      scenario = reactable::colDef(name = "Scenario"),
      period = reactable::colDef(name = "Period"),
      resolution = reactable::colDef(name = "Resolution"),
      path = reactable::colDef(
        name = "Link", 
        align = "left", 
        sortable = FALSE,
        html = TRUE, cell = function(value, index) {
          sprintf('<a href="%s" target="_blank">%s</a>', 
                  paste0("https://wbi-nwt.analythium.app/", LINKS$path[index]), "Link")
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

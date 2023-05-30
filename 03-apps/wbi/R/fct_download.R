


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
      element = reactable::colDef(show = FALSE),
      region = reactable::colDef(show = FALSE),
      scenario = reactable::colDef(name = "Scenario", align = "center"),
      period = reactable::colDef(name = "Time Period", align = "center"),
      link = reactable::colDef(
        name = "Link", 
        align = "center", 
        sortable = FALSE, 
        filterable = FALSE, 
        html = TRUE, 
        cell = function(value) {
          sprintf(
            '<a href="%s" target="_blank">%s</a>',
            value,
            "Download"
          )
        }
      )
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

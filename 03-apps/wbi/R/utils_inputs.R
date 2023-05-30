#' Look up the name of an element in a named character vector
#'
#' @description
#' This function was developed as an easy way to extract the corresponding name 
#'   from a named character vector given a value within that vector.
#' 
#' @param x A named character vector
#' @param value The value in `x` to use to look up the corresponding name
#'
#' @return A character string representing the name of the value in the vector
#'   specified by `value`
#' 
#' @noRd
#'
#' @examples
#' # The following code would return "Tamarack"
#' lookup_element_name_by_value(
#'   x = ELEMENT_NAMES$tree,
#'   value = "tree-lari-lar"
#' )
lookup_element_name_by_value <- function(x, value) {
  
  if (length(value) > 1L) {
    paste0(
      "`value` should be length 1, not length ",
      length(value), "."
    ) |> 
      stop()
  }
  
  x[x == value] |> names()
  
}


#' Look up the name of the list element based upon item in one list
#'
#' @description
#' This function was developed as a pipe-friendly way to extract the 
#'   corresponding name from a named character vector given a value within that
#'   vector.
#' 
#' @param x A list object
#' @param value The value in one of the lists of `x` to use to look up the 
#'   name of the list element(s) containing `x`
#'
#' @return A character string representing the name(s) of the list(s) containing
#'   `x`
#' 
#' @noRd
#'
#' @examples
#' # The following code would return "Tamarack"
#' lookup_element_type_by_value(
#'   x = ELEMENT_NAMES,
#'   value = "tree-lari-lar"
#' )
lookup_element_type_by_value <- function(x, value) {
  
  out <- sapply(
    x, 
    function(y) value %in% y
  )
  
  names(out[out == TRUE])
  
}



get_period_choices <- function(x) {
  
  out <- seq(
    from = x$year_start,
    to = x$year_end,
    by = x$year_interval
  )
  
  if (!x$year_end %in% out) {
    
    out <- c(out, x$year_end)
    
  }
  
  return(out)
  
}



#' Create a bootstrap accordion UI element
#' 
#' @description
#' In bootstrap 5.0 you can create an "accordion" object that allows you to 
#' collapse/expand the content inside the "accordion" container:
#' \link{https://getbootstrap.com/docs/5.0/components/accordion/}
#' 
#'
#' @param id (String) A unique id value for the accordion
#' @param header (String) The text to display in the header of the accordion
#'   (to the left of the 'collapse' button)
#' @param content The content (HTML, text, etc.) to be displayed within the 
#'   accordion
#'
#' @return An HTML div that will display `content` inside a vertically-
#'   collapsible bootstrap accordion
#' 
#' @noRd
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(bslib)
#' 
#'   ui <- page_fluid(
#'     build_accordion(
#'       id = "acc1", 
#'       header = "Open/Close Me", 
#'       content = tags$em("Here's some collapsible content")
#'     )
#'   )
#' 
#'   server <- function(input, output) {}
#' 
#'   shinyApp(ui, server)
#' }
build_accordion <- function(id, header, content) {
  
  # Create 'id' values for divs
  ids <- list(
    accordion = glue::glue("accordion_{id}"),
    header = glue::glue("heading_{id}"),
    collapse = glue::glue("collapse_{id}")
  )
  
  # Build accordion
  shiny::div(
    class = "accordion accordion-flush",
    id = ids$accordion,
    
    shiny::div(
      class = "accordion-item",
      
      shiny::h2(
        class = "accordion-header",
        id = ids$header,
        
        shiny::tags$button(
          class = "accordion-button",
          type = "button", 
          `data-bs-toggle` = "collapse",
          `data-bs-target` = glue::glue("#{ids$collapse}"),
          `aria-expanded` = "true",
          `aria-controls` = ids$collapse,
          header
        )
        
      ),
      
      shiny::div(
        id = ids$collapse,
        class = "accordion-collapse collapse show",
        `aria-labelledby` = ids$header,
        `data-bs-parent` = glue::glue("#{ids$accordion}"),
        
        shiny::div(
          class = "accordion-body",
          content
        )
        
      )
    )
  )
  
}



#' Create a bootstrap alert UI element
#' 
#' @description
#' In bootstrap 5.0 you can create an "alert" object that encapsulates content
#' in a colored box:
#' \link{https://getbootstrap.com/docs/5.0/components/alerts/}
#'
#' @param type (String) One of "primary", "secondary", "success", "info", 
#'   "danger", "warning", "light", "dark"
#' @param content The content (HTML, text, etc.) to be displayed within the 
#'   alert box
#'
#' @return An HTML div that will display `content` inside a bootstrap alert box
#' 
#' @noRd
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(bslib)
#' 
#'   ui <- page_fluid(
#'     build_alert(
#'       content = tags$em("Here's some content you should be alerted to")
#'     )
#'   )
#' 
#'   server <- function(input, output) {}
#' 
#'   shinyApp(ui, server)
#' }
build_alert <- function(type = "warning", content) {
  
  shiny::div(
    class = glue::glue("alert alert-{type}"),
    role = "alert",
    shiny::HTML(content)
  )
  
}

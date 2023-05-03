#' Look up the name in a named list that is associated with a particular value
#'
#' @description A utils function
#'
#' @return A character string representing the plain-English name
#'
#' @noRd
lookup_element_name_by_value <- function(list, type, value) {
  
  names(list[[type]][list[[type]] == value])
  
}



build_accordion <- function(id, header, content) {
  
  glue::glue("
    <div class=\"accordion accordion-flush\" id=\"accordion_{id}\">
      <div class=\"accordion-item\">
        <h2 class=\"accordion-header\" id=\"heading_{id}\">
          <button class=\"accordion-button\" type=\"button\" data-bs-toggle=\"collapse\" data-bs-target=\"#collapse_{id}\" aria-expanded=\"true\" aria-controls=\"collapse_{id}\">
             {header}
          </button>
        </h2>
        <div id=\"collapse_{id}\" class=\"accordion-collapse collapse show\" aria-labelledby=\"heading_{id}\" data-bs-parent=\"#accordionExample\">
          <div class=\"accordion-body\">
             {content}
          </div>
        </div>
      </div>
    </div>
  ") |> 
    shiny::HTML()
  
}

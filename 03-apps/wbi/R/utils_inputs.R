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

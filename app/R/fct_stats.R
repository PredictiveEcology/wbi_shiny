


#' Query Statistics from Pre-procesed Hypercube
#'
#' @description `get_stats()` queries the appropriate pre-processed values from
#'   the `STATS` data cube across the 'element' and 'regions' dimensions
#'  
#' @param element A string, indicating the element to retrieve statistics for
#' @param region A string, indicating the region to retrieve statistics for
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
#' 
#' @examples
#' get_stats(
#'   element = "bird-alfl", 
#'   region = "Ecoregions: 50"
#' )
get_stats <- function(element, region) {
  
  # Filter the data cube to retrieve the four scenario/year combinations for the 
  # input element
  elv <- dimnames(STATS$statistics)[[1]][grep(element, dimnames(STATS$statistics)[[1]])]
  
  # Build a data frame that separates the scenarios into three columns (element, 
  # scenario, and year)
  d <- data.frame(
    do.call(rbind, strsplit(elv, "/"))
  )
  
  # Assign column names to the data frame
  names(d) <- c("Element", "Scenario", "Year")
  
  # Add an "Index" column that serves as concatenation of element-scenario-year
  d$Index <- elv
  
  # Add a "Region" column using the input argument
  d$Region <- region
  
  # Add  "Mean" column by querying the related mean statistic from the data cube
  d$Mean <- STATS$statistics[elv, region, "Mean"]
  
  d
  
}

# 
# plot_stats <- function(d, ...) {
#   p <- ggplot(d,
#               aes(x = as.integer(Year),
#                   y = Mean,
#                   group = Scenario,
#                   fill = Scenario,
#                   col = Scenario)) +
#     geom_point() +
#     geom_line()
#   p
# }
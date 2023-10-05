


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
#'   region = "Alberta"
#' )
get_stats <- function(element, region) {
  
  # Filter the data cube to retrieve the four scenario/year combinations for the 
  # input element
  # elv <- dimnames(STATS$statistics)[[1]][grep(element, dimnames(STATS$statistics)[[1]])]
  elv <- rownames(STATS$elements)[STATS$elements$element == element]

  # Build a data frame that separates the scenarios into three columns (element, 
  # scenario, and year)
  # d <- data.frame(
  #   do.call(rbind, strsplit(elv, "/"))
  # )
  d <- STATS$elements[elv, c("element", "scenario", "period")]
  
  # Assign column names to the data frame
  names(d) <- c("Element", "Scenario", "Year")
  
  # add human readable species and scenario names
  d[["Element"]][] <- ELEMENTS[element, "common_name"]
  d[["Scenario"]] <- names(SCENARIOS)[match(d[["Scenario"]], unlist(SCENARIOS))]

  # Add an "Index" column that serves as concatenation of element-scenario-year
  d$Index <- elv

  # Add a "Region" column using the input argument
  d$Region <- region

  # Add  "Mean" column by querying the related mean statistic from the data cube
  d$Mean <- STATS$statistics$mean[elv, region]
  
  d
  
}



#' Build Trendline Chart
#'
#' @param data The resulting data frame output from the `get_stats()` function
#'
#' @return An interactive {echarts4r} line chart
#' 
#' @details Note that `dplyr::group_by()` is currently 
#' [exported from {echarts4r}](https://github.com/JohnCoene/echarts4r/blob/master/R/utils-exports.R), 
#' but it appears from recent commits in the GitHub repository that this may be 
#' subject to further ongoing development 
#' 
#' @noRd
#'
#' @examples
#' get_stats(
#'   element = "bird-alfl", 
#'   region = "Alberta"
#' ) |> 
#'   plot_trend()
#' @importFrom rlang .data
plot_trend <- function(data) {
  
  data |> 
    dplyr::group_by(.data$Scenario) |> 
    echarts4r::e_charts(.data$Year) |> 
    echarts4r::e_line(
      serie = .data$Mean, 
      symbol = "circle", 
      symbolSize = 15
    ) |> 
    echarts4r::e_axis_labels(
      x = "Year", 
      y = "Mean"
    ) |> 
    echarts4r::e_tooltip(trigger = "axis")
  
}

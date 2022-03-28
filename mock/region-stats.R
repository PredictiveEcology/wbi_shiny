library(sf)
library(ggplot2)

## this is the file in main: data/elements-regions-stats-250m.rds
STATS <- readRDS("_tmp/elements-regions-stats-250m.rds")

get_stats <- function(el, reg, STATS) {
    elv <- dimnames(STATS$statistics)[[1]][grep(el, dimnames(STATS$statistics)[[1]])]
    d <- data.frame(do.call(rbind, strsplit(elv, "/")))
    names(d) <- c("Element", "Scenario", "Year")
    d$Index <- elv
    d$Region <- reg
    d$Mean <- STATS$statistics[elv, reg, "Mean"]
    d
}

plot_stats <- function(d, ...) {
    p <- ggplot(d,
        aes(x = as.integer(Year),
            y = Mean,
            group = Scenario,
            fill = Scenario,
            col = Scenario)) +
        geom_point() +
        geom_line()
    p
}

map_region <- function(reg, STATS) {
    plot(STATS$regions[1,"geom"])
    plot(STATS$regions[reg,"geom"], col="gold", border="tomato", add=TRUE)
    invisible(NULL)
}

d <- get_stats(
    reg = "Ecoregions: 50",
    el = "bird-alfl",
    STATS = STATS)

plot_stats(d)

plotly::ggplotly(plot_stats(d))

d[,c("Scenario", "Year", "Mean")]

map_region(reg, STATS)

## UI
## - birds/trees redio button
## - elements dropdown
## - regions dropdown (use rownames(STATS$regions))
## - display interactive plot based on plot_stats (plotly or echarts)
## - display DT/reactable table for d[,c("Scenario", "Year", "Mean")]
## - update static map based on map_region()
##   if want to go fancy: use leaflet & overlay the polygon from STATS$regions


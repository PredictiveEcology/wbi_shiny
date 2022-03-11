## run the mock shiny app

shiny::runApp("mock")



# add interactive maps to a ggplot -------
library(ggplot2)
library(ggiraph)

z <- p[p$classification == "Ecoregions",]
z$labs <- sprintf("<p>%s</p>", paste("Ecoregion", z$region))

gg <- ggplot(z) +
    geom_sf(aes(fill = as.numeric(area))) +
    geom_sf_label_interactive(aes(label = labs, tooltip = labs))
x <- girafe( ggobj = gg)

mp <- map_data("world")
gg_map <- ggplot(z, aes(map_id = region))
gg_map <- gg_map + geom_map_interactive(aes(
                  tooltip = labs,
                  data_id = region
                ),
                map = mp)# +
                #expand_limits(x = mp$long, y = mp$lat)

x <- girafe(ggobj = gg_map)

if (require("maps") ) {
  states_map <- map_data("state")
  gg_map <- ggplot(crimes, aes(map_id = state))
  gg_map <- gg_map + geom_map_interactive(aes(
                  fill = Murder,
                  tooltip = labs,
                  data_id = state,
                  onclick = onclick
                ),
                map = states_map) +
    expand_limits(x = states_map$long, y = states_map$lat)
  x <- girafe(ggobj = gg_map)
  if( interactive() ) print(x)
}

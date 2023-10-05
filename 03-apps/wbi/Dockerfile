FROM eddelbuettel/r2u:jammy

RUN install2.r --error bslib shiny leaflet config sf reactable leaflet.extras2 golem echarts4r ggplot2 leafem shinyWidgets viridis

# RUN Rscript -e 'remotes::install_github("psolymos/shinyBS@86c427aed776fc6d5c4efcee0112e4c22c81a95e")'

RUN mkdir ./build_zone
ADD . ./build_zone
WORKDIR ./build_zone
RUN R -e 'remotes::install_local(upgrade="never")'
RUN rm -rf ./build_zone

RUN addgroup --system shiny && adduser --system --ingroup shiny shiny
USER shiny

EXPOSE 8080
ENV R_CONFIG_ACTIVE=production
CMD R -e "options('shiny.port'=8080,shiny.host='0.0.0.0');library(ShinyWBI);library(sf);run_app()"

FROM eddelbuettel/r2u:jammy
# FROM rocker/r-ver:4.1.1

RUN apt-get update && apt-get install -y  gdal-bin git-core libcurl4-openssl-dev libgdal-dev libgeos-dev libgeos++-dev libgit2-dev libicu-dev libpng-dev libproj-dev libssl-dev libudunits2-dev libxml2-dev make pandoc pandoc-citeproc zlib1g-dev && rm -rf /var/lib/apt/lists/*

RUN install.r bslib shiny leaflet config sf reactable leaflet.extras2 golem echarts4r ggplot2 leafem
# RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" >> /usr/local/lib/R/etc/Rprofile.site
# RUN R -e 'install.packages("remotes")'
# RUN Rscript -e 'remotes::install_version("bslib",upgrade="never", version = "0.3.1")'
# RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.7.1")'
# RUN Rscript -e 'remotes::install_version("leaflet",upgrade="never", version = "2.1.0")'
# RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3.1")'
# RUN Rscript -e 'remotes::install_version("sf",upgrade="never", version = "1.0-6")'
# RUN Rscript -e 'remotes::install_version("reactable",upgrade="never", version = "0.2.3")'
# RUN Rscript -e 'remotes::install_version("leaflet.extras2",upgrade="never", version = "1.1.0")'
# RUN Rscript -e 'remotes::install_version("golem",upgrade="never", version = "0.3.2")'
# RUN Rscript -e 'remotes::install_version("echarts4r",upgrade="never", version = "0.4.3")'
# RUN Rscript -e 'remotes::install_version("ggplot2",upgrade="never", version = "3.3.5")'

RUN Rscript -e 'remotes::install_github("psolymos/shinyBS@86c427aed776fc6d5c4efcee0112e4c22c81a95e")'

RUN mkdir ./build_zone
ADD . ./build_zone
WORKDIR ./build_zone
RUN R -e 'remotes::install_local(upgrade="never")'
RUN rm -rf ./build_zone

RUN addgroup --system shiny && adduser --system --ingroup shiny shiny
USER shiny

EXPOSE 8080
ENV R_CONFIG_ACTIVE=production
CMD R -e "options('shiny.port'=8080,shiny.host='0.0.0.0');library(ShinyWBInwt);library(sf);run_app()"

# Shiny App

A {golem} project (i.e., an R package) containing the logic needed to run the WBI Shiny app.

## What is {golem}?

> "[{golem}](https://thinkr-open.github.io/golem/) is an opinionated framework for building production-grade shiny applications" - Colin Fay, package author

{golem} approaches building Shiny apps as *R packages*. There are several benefits of this approach, including:

* enforcement of *roxygen* documentation
* separation of business logic from app logic
* definition of package dependencies

For further reading into {golem} and building production-grade shiny applications, we recommend checking out the accompanying book, [*Engineering Production-Grade Shiny Apps*](https://engineering-shiny.org/).

## How to Use This App

Make sure you are running any app-related scripts within the [app.Rproj file](app.Rproj) project file. To test run the app, run the [run_dev.R](dev/run_dev.R) script

## Structure

The structure of this Shiny app / R package can be described as follows:

* [data/](data/) contains the datasets included with the package
* [data-raw/](data-raw/) contains the raw data & scripts used to generate the package data in [data/](data/)
* [dev/](dev/) contains helper scripts that you may find useful as you develop a {golem} app; they are not dependencies for the app and can be removed if desired
  + in particular, the [dev/run_dev.R] script is useful for running the app for testing purposes
* [inst/](inst/) contains mostly non-R styling & configuration components (e.g., CSS stylesheets, javascript helpers, favicon, etc.)
* [man/](man/) contains the roxygen-generated documentation; for the purposes of keeping the size of this package small, we currently did not generate **.Rd** files for any of the custom functions we developed in the [R/](R/) folder (we prevented this through the use of the `@noRd` tag in the roxygen headers for each function)
* [R/](R/) contains all of the app logic and business logic used in the app
  + [app_ui.R](R/app_ui.R) and [app_server.R](R/app_server.R) contain the overall UI & Server code that house the individual shiny modules
  + [fct_map.R](R/fct_map.R) contains the custom functions that generate the map visuals in the app (on the "Map" and "Side-by-Side" pages of the app)
  + [fct_stats.R](R/fct_stats.R) contains the custom functions that generate the map & table visuals on the "Regions" page
  + [fct_download.R](R/fct_download.R) contains the function that generates the table visual on the "Download" page
  + the `mod_*.R` scripts contain the modularized UI & Server components for each page in the app
  + [run_app.R](R/run_app.R) contains the function that renders the app; this script should not need to be modified
  + [app_config.R](R/app_config.R) contains low-level app configuration functions; this script should not need to be modified

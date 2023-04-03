# httpuv
library(httpuv)
handle <- function(req) {
  input <- req[["rook.input"]]
  postdata <- input$read_lines()
  jsonlite::toJSON(paste0("Hello ", 
    jsonlite::fromJSON(paste(postdata)), "!"))
}
httpuv::runServer(
  host = "0.0.0.0",
  port = 8080,
  app = list(
    call = function(req) {
      list(
        status = 200L,
        headers = list("Content-Type" = "application/json"),
        body = handle(req))
    }
  )
)
# curl http://localhost:8080/ -d '["Friend"]' \
#   -H 'Content-Type: application/json'

# plumber
library(plumber) # load plumber
handle <- function(req) {
  paste0("Hello ", jsonlite::fromJSON(paste(req$postBody)), "!")
}
pr() |>
  pr_post(
    "/",
    handler = handle,
    serializer = serializer_unboxed_json()) |>
  pr_run(host = "0.0.0.0", port = 8080)
# curl http://localhost:8080/ -d '["Friend"]' \
#   -H 'Content-Type: application/json'

# fiery - longer
library(fiery)
library(reqres)
handle <- function(request) {
  jsonlite::toJSON(paste0("Hello ", request$body, "!"))
}
app <- Fire$new(host = '0.0.0.0', port = 8080L)
app$on("request", function(server, id, request, ...) {
  OK <- request$parse(json = parse_json())
  response <- request$respond()
  if (OK) {
    result <- try(handle(request))
    if (inherits(result, "try-error")) {
      response$body <- jsonlite::toJSON(result)
      response$status <- 400L
    } else {
      response$body <- result
      response$status <- 200L
    }
  } else {
    response$body <- jsonlite::toJSON("Error: wrong input")
    response$status <- 400L
  }
  response$type <- "application/json; charset=utf-8"
})
app$ignite()
# curl http://localhost:8080/ -d '["Friend"]' \
#   -H 'Content-Type: application/json'

# fiery - shorter with routr
library(fiery)
library(reqres)
library(routr)
handle <- function(request, response, keys, ...) {
    request$parse(json = parse_json())
    response$status <- 200L
    response$type <- "application/json; charset=utf-8"
    response$body <- jsonlite::toJSON(paste0("Hello ", request$body, "!"))
    return(FALSE)
}
app <- Fire$new(host = "0.0.0.0", port = 8080L)
route <- Route$new()
route$add_handler('post', '/', handle)
router <- RouteStack$new()
router$add_route(route, "hello")
app$attach(router)
app$ignite()
# curl http://localhost:8080/ -d '["Friend"]' \
#   -H 'Content-Type: application/json'

# beakr
library(beakr)
handle <- function(req, res, err) {
  paste0("Hello ", jsonlite::fromJSON(paste(req$body)), "!")
}
newBeakr() |>
  httpPOST(
    path = "/",
    decorate(
      FUN = handle,
      content_type = "application/json"
    )
  ) |>
  handleErrors() |>
  listen(host = "0.0.0.0", port = 8080)
# curl http://localhost:8080/ -d '["Friend"]' \
#   -H 'Content-Type: application/json'

# ambiorix
# not on CRAN (archived)
# remotes::install_github("devOpifex/ambiorix")
library(ambiorix)
options(ambiorix.host = "0.0.0.0", ambiorix.port = 8080)
app <- Ambiorix$new()
handle <- function(body) {
  paste0("Hello ", body, "!")
}
app$post("/", function(req, res){
  res$json(handle(parse_json(req)))
})
app$start(open = FALSE)
# curl http://localhost:8080/ -d '["Friend"]' \
#   -H 'Content-Type: application/json'

# RestRserve
library(RestRserve)
handle = function(.req, .res) {
  .res$set_body(paste0("Hello ", .req$body, "!"))
}
app = Application$new(
  content_type = "application/json")
app$add_post(
  path = "/",
  FUN = handle)
backend = BackendRserve$new()
backend$start(app, http_port = 8080)
# curl http://localhost:8080/ -d '["Friend"]' \
#   -H 'Content-Type: application/json'

# opencpu
library(opencpu)
ocpu_start_server(
  port = 8080,
  root = "/",
  workers = 1,
  preload = NULL,
  on_startup = NULL,
  no_cache = FALSE)
# curl http://localhost:8080/library/base/R/paste/json \
#   -H 'Content-Type: application/json' \
#   -d '{"x":["Hello","Friend","!"],"collapse":" "}'

# Rserve
library(Rserve)
.http.request <- function(url, query, body, headers) {
  paste0("Hello ", jsonlite::fromJSON(rawToChar(body)), "!")
}
Rserve::run.Rserve(http.port = 8080)
# curl http://localhost:8080/ -d '["Friend"]' \
#   -H 'Content-Type: application/json'

# check download stats
library(ggplot2)
library(dlstats)

pkg <- c("httpuv", "opencpu", "plumber", "fiery", "beakr", "RestRserve", "ambiorix", "Rserve", "shiny")
x <- cran_stats(pkg)
ggplot(x, aes(x = end, y = downloads, group=package, color=package)) +
  geom_line() + 
  scale_colour_brewer(palette = "Set1") +
  theme_minimal()
